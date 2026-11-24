#!/usr/bin/python3
import glob, hashlib, os, re, subprocess, sys

def run(*args):
    p = subprocess.run(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    return p.stdout if p.returncode == 0 else ''
def key(kind, name): return hashlib.sha256((kind + ':' + name).encode()).hexdigest()
def lit(s): return "'" + str(s).replace("'", "''").replace('\n',' ') + "'"
nodes = {}
edges = set()
def node(kind, name, version='', detail=''):
    k = key(kind, name)
    old = nodes.get(k, (kind, name, '', ''))
    nodes[k] = (kind, name, version or old[2], detail or old[3])
    return k
def edge(a,b,kind,detail=''): edges.add((a,b,kind,detail))
packages = run('rpm','-qa','--qf','%{NAME}\\t%{VERSION}-%{RELEASE}\\n').splitlines()
for line in packages:
    if '\t' not in line: continue
    name, version = line.split('\t',1)
    src = node('RPM',name,version)
    for req in run('rpm','-q','--requires',name).splitlines():
        if not req or req.startswith('rpmlib('): continue
        cap = node('CAPABILITY',req)
        edge(src,cap,'REQUIRES',req)
        for provider in run('rpm','-q','--whatprovides',req,'--qf','%{NAME}\\n').splitlines():
            if provider and not provider.startswith('no package'):
                pk = node('RPM',provider)
                edge(cap,pk,'PROVIDED_BY')
# Restore version metadata after provider discovery.
for line in packages:
    if '\t' in line:
        name,version=line.split('\t',1); node('RPM',name,version)
for path in sorted(glob.glob('/usr/pgsql-*/share/extension/*.control')):
    name=os.path.basename(path)[:-8]
    content=open(path,encoding='utf-8',errors='replace').read()
    v=re.search(r"^\s*default_version\s*=\s*'([^']*)'",content,re.M)
    ext=node('EXTENSION',name,v.group(1) if v else '',path)
    for owner in run('rpm','-qf',path,'--qf','%{NAME}\\n').splitlines():
        if owner and not owner.startswith('file '): edge(ext,node('RPM',owner),'PACKAGED_IN')
    m=re.search(r"^\s*requires\s*=\s*'([^']*)'",content,re.M)
    if m:
        for dep in m.group(1).split(','):
            dep=dep.strip()
            if dep: edge(ext,node('EXTENSION',dep),'REQUIRES_EXTENSION')
print('WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK')
for k,(kind,name,ver,detail) in sorted(nodes.items()):
    print('INSERT INTO pgdep_vertex (id, kind, name, version, detail) VALUES (%s);' % ', '.join(map(lit,(k,kind,name,ver,detail))))
for a,b,kind,detail in sorted(edges):
    eid=key('EDGE',a+'|'+b+'|'+kind+'|'+detail)
    print('INSERT INTO pgdep_edge (id, source_id, target_id, kind, detail) VALUES (%s);' % ', '.join(map(lit,(eid,a,b,kind,detail))))
print('COMMIT;')
print('-- vertices: %d; edges: %d' % (len(nodes),len(edges)))
