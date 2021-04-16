echo "=> Add application user"
$JBOSS_HOME/bin/add-user.sh --silent=true -a testJNDI 123456
echo "testJNDI=testrole" >> $JBOSS_HOME/standalone/configuration/application-roles.properties
echo "testJNDI=testrole" >> $JBOSS_HOME/domain/configuration/application-roles.properties
