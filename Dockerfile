FROM rockylinux:9
ARG PG_MAJOR=18
RUN dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-$(uname -m)/pgdg-redhat-repo-latest.noarch.rpm \
 && dnf -qy module disable postgresql \
 && dnf -y install dnf-plugins-core python3 postgresql${PG_MAJOR}-server postgresql${PG_MAJOR}-contrib \
 && dnf -y install epel-release \
 && dnf config-manager --set-enabled crb
COPY install-extensions.sh /usr/local/bin/install-extensions
RUN PG_MAJOR=${PG_MAJOR} /usr/local/bin/install-extensions
COPY export-graph.py /usr/local/bin/export-graph
ENV PG_MAJOR=${PG_MAJOR}
CMD ["/bin/bash"]
