#!/bin/bash

# Set environment variables
DATASOURCE=java:/jdbc/datasources/${DB_NAME}DS

# Setup WildFly admin user
echo "=> Add WildFly administrator"
$JBOSS_HOME/bin/add-user.sh -u $WILDFLY_USER -p $WILDFLY_PASS --silent

# Configure datasource
echo "=> Create datasource: '${DATASOURCE}'"
$JBOSS_CLI << EOF
embed-server --server-config=standalone.xml
batch

# Add MySQL module
module add \
  --name=com.mysql \
  --resources=/tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.jar \
  --dependencies=javax.api,javax.transaction.api

# Configure driver
/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql,driver-xa-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource)

# Add new datasource
data-source add \
  --name=${DB_NAME}Pool \
  --jndi-name=${DATASOURCE} \
  --user-name=${DB_USER} \
  --password=${DB_PASS} \
  --driver-name=mysql \
  --connection-url=jdbc:mysql://${DB_URI}/${DB_NAME} \
  --use-ccm=false \
  --max-pool-size=25 \
  --blocking-timeout-wait-millis=5000 \
  --enabled=true

# Execute the batch
run-batch
reload
stop-embedded-server
EOF

echo "=> Clean up"
## FIX for Error: WFLYCTL0056: Could not rename /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current...
rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/* \
       $JBOSS_HOME/standalone/log/* \
       /tmp/*.jar
unset WILDFLY_USER WILDFLY_PASS DB_NAME DB_USER DB_PASS DATASOURCE

extra_args=

if [[ "$WILDFLY_DEBUG" = "true" ]]; then
    echo "=> Enable debug mode"
    extra_args="$extra_args --debug"
fi
    
echo "=> Start WildFly"
# Boot WildFly in standalone mode and bind it to all interfaces (enable admin console and debug)
$JBOSS_HOME/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 $extra_args
