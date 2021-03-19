ARG WILDFLY_VER=23.0.0.Final

FROM jboss/wildfly:${WILDFLY_VER}

# Enviorment variables
ENV WILDFLY_DEBUG false
ENV WILDFLY_USER admin
ENV WILDFLY_PASS pass

ENV DB_NAME sample
ENV DB_USER mysql
ENV DB_PASS mysql
ENV DB_URI localhost:3306

# Download MySQL driver
ARG MYSQL_CONNECTOR_VERSION=8.0.23
ENV MYSQL_CONNECTOR_VERSION ${MYSQL_CONNECTOR_VERSION}

RUN echo "=> Downloading MySQL driver" && \
      curl --location \
           --output /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
           --url http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar

ENV JBOSS_CLI /opt/jboss/wildfly/bin/jboss-cli.sh
ENV DEPLOYMENT_DIR /opt/jboss/wildfly/standalone/deployments/

# Fix debug problem
RUN sed -i "s/JAVA_OPTS=\"\$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,address=\$DEBUG_PORT,server=y,suspend=n\"/JAVA_OPTS=\"\$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,address=*:\$DEBUG_PORT,server=y,suspend=n\"/" $JBOSS_HOME/bin/standalone.sh

# Expose http and admin ports and debug port
EXPOSE 8080 9990 8787

ADD docker-entrypoint.sh /opt/jboss/wildfly/customization/
CMD ["/opt/jboss/wildfly/customization/docker-entrypoint.sh"]
