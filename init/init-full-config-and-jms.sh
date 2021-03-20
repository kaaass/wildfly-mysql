# Switch to full configuration
echo "=> Switch to full configuration"
cp ${JBOSS_HOME}/standalone/configuration/standalone-full.xml ${JBOSS_HOME}/standalone/configuration/standalone.xml

# Add JMS role
echo "=> Add JMS role"
sed -i 's/<permission type="send" roles="guest"\/>/<permission type="send" roles="guest testrole"\/>/' \
    ${JBOSS_HOME}/standalone/configuration/standalone.xml
sed -i 's/<permission type="consume" roles="guest"\/>/<permission type="consume" roles="guest testrole"\/>/' \
    ${JBOSS_HOME}/standalone/configuration/standalone.xml
