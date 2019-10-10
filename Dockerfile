FROM alpine:3.6

MAINTAINER Chiho Sin <chihosin@outlook.com>

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre
ENV PENTAHO_VERSION=8.3 \
    PDI_BUILD=8.3.0.0-371 \
    JRE_HOME=${JAVA_HOME} \
    PENTAHO_JAVA_HOME=${JAVA_HOME} \
    PENTAHO_HOME=/opt/pentaho \
    KETTLE_HOME=/opt/pentaho/data-integration\
    PATH=${PATH}:${JAVA_HOME}/bin
RUN echo  wget -qO /tmp/pdi-ce.zip https://downloads.sourceforge.net/project/pentaho/Pentaho%20${PENTAHO_VERSION}/client-tools/pdi-ce-${PDI_BUILD}.zip
RUN apk update && \
    apk --no-cache add libressl && \
    apk add openjdk8-jre bash webkitgtk && \
    apk add --virtual build-dependencies ca-certificates openssl && \
    update-ca-certificates 
RUN mkdir -p ${PENTAHO_HOME}
RUN wget -qO /tmp/pdi-ce.zip https://downloads.sourceforge.net/project/pentaho/Pentaho%20${PENTAHO_VERSION}/client-tools/pdi-ce-${PDI_BUILD}.zip && \
    unzip -q /tmp/pdi-ce.zip -d ${PENTAHO_HOME} && \
    rm -f /tmp/pdi-ce.zip && \
    apk del build-dependencies && \
    chmod -R g+w ${PENTAHO_HOME}

# Patch to restore images https://jira.pentaho.com/browse/PDI-17948
RUN wget -qO /tmp/static.tgz https://jira.pentaho.com/secure/attachment/100366/data-integration-static-folder.gz && \
    gzip -dc /tmp/static.tgz |tar -xvf - -C /opt/pentaho/data-integration/


ADD docker-entrypoint.sh $KETTLE_HOME/docker-entrypoint.sh

VOLUME ["/opt/pentaho/repository"]
EXPOSE 7373

WORKDIR $KETTLE_HOME
CMD ["/bin/bash", "./docker-entrypoint.sh", "master"]
