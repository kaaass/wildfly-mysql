FROM jboss/base-jdk:7

#################
# Install JBoss #
#################

# Set the WILDFLY_VERSION env variable
ARG WILDFLY_VER=7.1.1.Final
ENV WILDFLY_VERSION ${WILDFLY_VER}
ENV WILDFLY_SHA1 fcec1002dce22d3281cc08d18d0ce72006868b6f
ENV JBOSS_HOME /opt/jboss/jbossas
ENV JBOSS_MODULES_SHA1 8a63dba6eec1e9bd1680ec929c1257773fb50dd4

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/jbossas/7.1/jboss-as-$WILDFLY_VERSION/jboss-as-$WILDFLY_VERSION.tar.gz \
    && sha1sum jboss-as-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf jboss-as-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/jboss-as-$WILDFLY_VERSION $JBOSS_HOME \
    && rm jboss-as-$WILDFLY_VERSION.tar.gz \
    && curl -O https://repo1.maven.org/maven2/org/jboss/modules/jboss-modules/1.1.5.GA/jboss-modules-1.1.5.GA.jar \
    && sha1sum jboss-modules-1.1.5.GA.jar | grep $JBOSS_MODULES_SHA1 \
    && mv $HOME/jboss-modules-1.1.5.GA.jar $JBOSS_HOME/jboss-modules.jar \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Change listening address
RUN sed -i -r 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:0.0.0.0/' \
    ${JBOSS_HOME}/standalone/configuration/standalone.xml

###################
# Configure MySQL #
###################

# Enviorment variables
ENV WILDFLY_DEBUG false
ENV WILDFLY_USER admin
ENV WILDFLY_PASS pass

ENV DB_NAME sample
ENV DB_USER mysql
ENV DB_PASS mysql
ENV DB_URI localhost:3306

ENV DEPLOYMENT_DIR ${JBOSS_HOME}/standalone/deployments/

# Download MySQL driver
ARG MYSQL_CONNECTOR_VERSION=5.1.26

ADD module.xml ${JBOSS_HOME}/modules/com/mysql/main/
USER root
RUN echo "=> Downloading MySQL driver" && \
      curl --location \
           --output ${JBOSS_HOME}/modules/com/mysql/main/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
           --url http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar && \
      sed -i "s/\${MYSQL_CONNECTOR_VERSION}/${MYSQL_CONNECTOR_VERSION}/" ${JBOSS_HOME}/modules/com/mysql/main/module.xml && \
      chown -R jboss:0 ${JBOSS_HOME}/modules/com/mysql && \
      chmod -R g+rw ${JBOSS_HOME}/modules/com/mysql
USER jboss

# Expose http and admin ports and debug port
EXPOSE 8080 9990 8787

ADD docker-entrypoint.sh ${JBOSS_HOME}/customization/
CMD ["/opt/jboss/jbossas/customization/docker-entrypoint.sh"]
