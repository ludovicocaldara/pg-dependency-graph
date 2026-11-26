#!/usr/bin/env python3
"""Collect PostgreSQL ELF roots and external shared-library dependencies as Oracle SQL."""
import argparse
from collections import Counter, defaultdict, deque
from datetime import datetime, timezone
import hashlib
import json
import os
import platform
import re
import shutil
import subprocess
import sys


def run(args):
    return subprocess.run(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)


def ident(*parts):
    return hashlib.sha256(json.dumps(parts, ensure_ascii=False, separators=(',', ':')).encode()).hexdigest()


def sql(value):
    if value is None or value == '':
        return 'NULL'
    value = str(value)
    if len(value.encode('utf-8')) > 3800:
        raise ValueError('SQL value exceeds safe literal size: ' + value[:80])
    return "'" + value.replace("'", "''") + "'"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--pg-config', default='pg_config', help='path to pg_config in the target environment')
    ap.add_argument('--pg-home', help='PostgreSQL installation root; default: parent of pg_config --bindir')
    args = ap.parse_args()
    if not sys.platform.startswith('linux'):
        ap.error('run inside the target Linux environment')
    for tool in ('ldd', 'readelf', args.pg_config):
        if not shutil.which(tool):
            ap.error('required tool not found: ' + tool)
    def config(flag):
        p = run([args.pg_config, flag])
        if p.returncode:
            raise RuntimeError('pg_config ' + flag + ': ' + p.stderr.strip())
        return p.stdout.strip()
    bindir = os.path.realpath(config('--bindir'))
    libdir = os.path.realpath(config('--pkglibdir'))
    # pg_config exposes bindir, not a prefix switch. Avoid treating an entire
    # system hierarchy as PostgreSQL-owned when a distro installs into /usr.
    prefix = os.path.realpath(args.pg_home or os.path.dirname(bindir))
    if not args.pg_home and (prefix in ('/', '/usr', '/usr/local') or os.path.commonpath((prefix, libdir)) != prefix):
        raise RuntimeError('cannot safely infer PostgreSQL home; pass --pg-home explicitly')
    if not os.path.isdir(prefix) or not os.path.isdir(libdir):
        raise RuntimeError('PostgreSQL prefix or library directory does not exist')
    roots = []
    for name in ('postgres', 'psql'):
        path = os.path.realpath(os.path.join(bindir, name))
        if not os.path.isfile(path):
            raise RuntimeError('required executable not found: ' + path)
        roots.append(('POSTGRES_BINARY', path))
    seen_paths = set()
    skipped = []
    for directory, dirs, files in os.walk(libdir):
        dirs.sort()
        for name in sorted(files):
            if not re.search(r'\.so(?:\.|$)', name):
                continue
            path = os.path.realpath(os.path.join(directory, name))
            if path in seen_paths or not os.path.isfile(path):
                continue
            seen_paths.add(path)
            try:
                with open(path, 'rb') as f:
                    if f.read(4) != b'\x7fELF':
                        skipped.append({'path': path, 'reason': 'not an ELF object'})
                        continue
            except OSError as exc:
                skipped.append({'path': path, 'reason': str(exc)})
                continue
            roots.append(('PG_LIBRARY', path))
    # Use explicit primary extension control metadata; a library may be shared
    # by several extensions. Do not infer names from similar filenames.
    extension_dir = os.path.join(config('--sharedir'), 'extension')
    extension_names = defaultdict(set)
    control_paths = {}
    control_warnings = []
    if not os.path.isdir(extension_dir):
        control_warnings.append('extension control directory is missing: ' + extension_dir)
    else:
        for filename in sorted(os.listdir(extension_dir)):
            if not filename.endswith('.control') or '--' in filename:
                continue
            control = os.path.join(extension_dir, filename)
            try:
                with open(control, encoding='utf-8') as f:
                    text = f.read()
            except (OSError, UnicodeError) as exc:
                control_warnings.append(control + ': ' + str(exc))
                continue
            match = re.search(r"(?m)^\s*module_pathname\s*=\s*'([^']+)'", text)
            if not match:
                continue
            module = match.group(1)
            if module.startswith('$libdir/'):
                candidate = os.path.join(libdir, module[len('$libdir/'):])
            elif module.startswith('/'):
                candidate = module
            elif '/' not in module:
                # PostgreSQL normally searches $libdir for unqualified names.
                candidate = os.path.join(libdir, module)
            else:
                control_warnings.append(control + ': unsupported module_pathname ' + module)
                continue
            if not re.search(r'\.so(?:\.\d+)*$', candidate):
                candidate += '.so'
            candidate = os.path.realpath(candidate)
            if os.path.isfile(candidate):
                extension_name = filename[:-len('.control')]
                extension_names[candidate].add(extension_name)
                control_paths[extension_name] = control
            else:
                control_warnings.append(control + ': library not found: ' + candidate)
    snapshot = ident(datetime.now(timezone.utc).isoformat(), os.urandom(16).hex())
    nodes, links, warnings, failures = {}, {}, [], []
    dynamic_cache = {}
    major_match = re.search(r'PostgreSQL\s+(\d+)', config('--version'))
    major = major_match.group(1) if major_match else None
    owner_cache = {}
    def package_owner(path):
        if path not in owner_cache:
            if not path or not shutil.which('rpm'):
                owner_cache[path] = None
            else:
                p = run(['rpm', '-qf', '--qf', '%{NAME}', path])
                owner_cache[path] = p.stdout.strip() if p.returncode == 0 else None
        return owner_cache[path]
    def package_origin(package):
        if not package or not major:
            return 'UNKNOWN'
        base = 'postgresql' + major
        if package in (base, base + '-server', base + '-libs'):
            return 'POSTGRES_CORE'
        if package.startswith(base + '-'):
            return 'POSTGRES_DISTRIB'
        return 'THIRD_PARTY'
    def add_node(kind, name, path=None, detail=None):
        k = ident(snapshot, kind, path or name)
        package = package_owner(path) if kind in ('PG_LIBRARY', 'POSTGRES_BINARY', 'EXTENSION') else None
        if kind == 'SHARED_LIBRARY':
            category, origin = 'EXTERNAL', 'EXTERNAL'
        elif kind == 'UNRESOLVED':
            category, origin = 'UNKNOWN', 'UNKNOWN'
        else:
            origin = package_origin(package)
            if kind == 'POSTGRES_BINARY':
                category = 'POSTGRES_CORE'
            elif kind == 'EXTENSION' or path in extension_names:
                category = 'EXTENSION'
            elif origin in ('POSTGRES_CORE', 'POSTGRES_DISTRIB'):
                category = origin
            else:
                category = 'UNKNOWN'
        nodes[k] = (k, snapshot, kind, name, path, detail, category, origin, package)
        return k
    def add_link(source, target, via=None, kind='REQUIRES_EXTERNAL'):
        k = ident(snapshot, source, target, kind)
        if k not in links:
            links[k] = (k, snapshot, source, target, kind, via or None)
    def trace(path):
        p = run(['ldd', path])
        if p.returncode:
            raise RuntimeError((p.stderr or p.stdout).strip() or 'ldd failed')
        result = {}
        for line in p.stdout.splitlines():
            line = line.strip()
            match = re.match(r'(.+?)\s+=>\s+(not found|/.*?)(?:\s+\(0x[0-9a-fA-F]+\))?$', line)
            if match:
                result[match.group(1)] = None if match.group(2) == 'not found' else os.path.realpath(match.group(2))
            elif line.startswith('/'):
                name = line.split(' (0x', 1)[0]
                result[os.path.basename(name)] = os.path.realpath(name)
        return result
    def needed(path):
        if path not in dynamic_cache:
            p = run(['readelf', '-d', path])
            if p.returncode:
                raise RuntimeError('readelf failed for ' + path + ': ' + p.stderr.strip())
            dynamic_cache[path] = re.findall(r'\(NEEDED\).*?\[([^]]+)\]', p.stdout)
        return dynamic_cache[path]
    def internal(path):
        return os.path.commonpath((prefix, path)) == prefix
    for kind, path in roots:
        root = add_node(kind, os.path.basename(path), path)
        if kind == 'PG_LIBRARY':
            for extension_name in sorted(extension_names.get(path, ())):
                extension = add_node('EXTENSION', extension_name, control_paths[extension_name])
                add_link(extension, root, kind='USES_LIBRARY')
        try:
            resolved = trace(path)
        except RuntimeError as exc:
            failures.append({'path': path, 'reason': str(exc)})
            continue
        pending = deque([(path, root, ())])
        visited = set()
        while pending:
            current, parent, via = pending.popleft()
            state = (current, parent)
            if state in visited:
                continue
            visited.add(state)
            try:
                deps = needed(current)
            except RuntimeError as exc:
                warnings.append({'root': path, 'error': str(exc)})
                continue
            for name in deps:
                dest = resolved.get(name)
                if dest is None and name.startswith('/') and os.path.isfile(name):
                    dest = os.path.realpath(name)
                if dest is None or not os.path.isfile(dest):
                    detail = 'not resolved in root ldd output' if dest is None else 'resolved path not accessible: ' + dest
                    v = add_node('UNRESOLVED', name, detail=detail)
                    add_link(parent, v, ' → '.join(via))
                elif internal(dest):
                    pending.append((dest, parent, via + (dest,)))
                else:
                    v = add_node('SHARED_LIBRARY', os.path.basename(dest), dest)
                    add_link(parent, v, ' → '.join(via))
                    pending.append((dest, v, ()))
    now = datetime.now(timezone.utc).isoformat()
    counts = dict(Counter(v[2] for v in nodes.values()))
    metadata = {'snapshot_id': snapshot, 'pg_version': config('--version'), 'prefix': prefix, 'bindir': bindir,
                'pkglibdir': libdir, 'architecture': platform.machine(), 'kernel': platform.release(),
                'collected_utc': now, 'ld_library_path': os.environ.get('LD_LIBRARY_PATH'), 'counts': counts,
                'edge_count': len(links), 'categories': dict(Counter(v[6] for v in nodes.values())),
                'extension_mapped_libraries': sum(1 for v in nodes.values() if v[2] == 'PG_LIBRARY' and v[6] == 'EXTENSION'),
                'control_warnings': control_warnings, 'failed_roots': failures, 'skipped_files': skipped, 'warnings': warnings}
    print('SET DEFINE OFF')
    print('WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK')
    print('INSERT INTO pg_elf_snapshot (id, pg_version, prefix_path, bindir, pkglibdir, architecture, kernel, collected_utc, ld_library_path, note) VALUES (%s);' % ', '.join(map(sql, [snapshot, metadata['pg_version'], prefix, bindir, libdir, metadata['architecture'], metadata['kernel'], now, metadata['ld_library_path'], 'Root ldd traces mapped to DT_NEEDED; internal paths collapsed; dlopen not observed.'])))
    for row in sorted(nodes.values()):
        print('INSERT INTO pg_elf_vertex (id, snapshot_id, kind, name, path, detail, category, origin, owner_package) VALUES (%s);' % ', '.join(map(sql, row)))
    for row in sorted(links.values()):
        print('INSERT INTO pg_elf_edge (id, snapshot_id, source_id, target_id, kind, via) VALUES (%s);' % ', '.join(map(sql, row)))
    print('COMMIT;')
    print('-- snapshot: ' + snapshot)
    print(json.dumps(metadata, ensure_ascii=False, indent=2), file=sys.stderr)
    if failures or skipped or warnings or control_warnings:
        print('WARNING: collection has failures or skipped files; inspect the report.', file=sys.stderr)


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError, ValueError) as exc:
        print('ERROR: ' + str(exc), file=sys.stderr)
        sys.exit(1)
