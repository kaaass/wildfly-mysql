ARG WILDFLY_VER=7.1.1

FROM pascalgrimaud/jboss-as:${WILDFLY_VER}

RUN apt-get -y update && apt-get -y install curl
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enviorment variables
ENV WILDFLY_DEBUG false
ENV WILDFLY_USER admin
ENV WILDFLY_PASS pass

ENV DB_NAME sample
ENV DB_USER mysql
ENV DB_PASS mysql
ENV DB_URI localhost:3306

ENV JBOSS_HOME /opt/jboss-as
ENV DEPLOYMENT_DIR ${JBOSS_HOME}/standalone/deployments/
RUN mv /opt/jboss-as-7.1.1.Final ${JBOSS_HOME}

# Download MySQL driver
ARG MYSQL_CONNECTOR_VERSION=5.1.26

ADD module.xml ${JBOSS_HOME}/modules/com/mysql/main/
RUN echo "=> Downloading MySQL driver" && \
      curl --location \
           --output ${JBOSS_HOME}/modules/com/mysql/main/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
           --url http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar && \
      sed -i "s/\${MYSQL_CONNECTOR_VERSION}/${MYSQL_CONNECTOR_VERSION}/" ${JBOSS_HOME}/modules/com/mysql/main/module.xml


# Expose http and admin ports and debug port
EXPOSE 8080 9990 8787

ADD docker-entrypoint.sh ${JBOSS_HOME}/customization/
CMD ["/opt/jboss-as/customization/docker-entrypoint.sh"]
