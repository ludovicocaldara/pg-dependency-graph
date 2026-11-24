FROM oraclelinux:9
# Obtain the ARM64 server RPM from Oracle Graph Server and Client separately.
COPY oracle-graph-26.4.1.aarch64.rpm /tmp/oracle-graph.aarch64.rpm
RUN dnf -y install java-21-openjdk-headless python3 shadow-utils tar gzip findutils openssl && \
    dnf -y install /tmp/oracle-graph.aarch64.rpm && \
    rm -f /tmp/oracle-graph.aarch64.rpm && dnf clean all && \
    cp /etc/pki/java/cacerts /etc/oracle/graph/client-truststore.jks && \
    keytool -exportcert -alias pgx -keystore /etc/oracle/graph/server_keystore.jks -storepass changeit -rfc | keytool -importcert -noprompt -alias pgx-local -keystore /etc/oracle/graph/client-truststore.jks -storepass changeit && \
    useradd --create-home --groups oraclegraph graphapp && \
    chgrp -R oraclegraph /etc/oracle/graph /var/log/oracle/graph /opt/oracle/graph && \
    chmod -R g+rwX /etc/oracle/graph /var/log/oracle/graph /opt/oracle/graph
COPY start-graph.sh /usr/local/bin/start-graph
ENV PGX_SERVER_KEYSTORE_PASSWORD=changeit
USER graphapp
EXPOSE 7007
ENTRYPOINT ["/usr/local/bin/start-graph"]
