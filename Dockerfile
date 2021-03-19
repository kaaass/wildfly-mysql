ARG WILDFLY_VER=13.0.0.Final

FROM jboss/wildfly:${WILDFLY_VER}

# Appserver
ENV WILDFLY_USER admin
ENV WILDFLY_PASS adminPassword

# Database
ARG MYSQL_CONNECTOR_VERSION=8.0.23
ENV MYSQL_CONNECTOR_VERSION ${MYSQL_CONNECTOR_VERSION}

RUN echo "=> Downloading MySQL driver" && \
      curl --location \
           --output /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
           --url http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar

ENV DB_NAME sample
ENV DB_USER mysql
ENV DB_PASS mysql
ENV DB_URI db:3306

ENV JBOSS_CLI /opt/jboss/wildfly/bin/jboss-cli.sh
ENV DEPLOYMENT_DIR /opt/jboss/wildfly/standalone/deployments/

# Expose http and admin ports and debug port
EXPOSE 8080 9990 8787

ADD docker-entrypoint.sh /opt/jboss/wildfly/customization/
CMD ["/opt/jboss/wildfly/customization/docker-entrypoint.sh"]
