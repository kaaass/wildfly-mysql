#!/bin/bash
set -e

if [[ ! -f $JBOSS_HOME/.setup ]]; then

    # run init script
    if (ls ${JBOSS_HOME}/customization/init.d/* 1> /dev/null 2>&1); then
        for f in ${JBOSS_HOME}/customization/init.d/*; do
            echo "=> Run custom init script '$f'"
            bash "$f" 
        done
    fi

    # change listening port
    sed -i -r 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:0.0.0.0/' \
        ${JBOSS_HOME}/standalone/configuration/standalone.xml

    # Set environment variables
    DATASOURCE=java:jboss/datasources/${DB_NAME}DS

    # Setup JBoss admin user
    echo "=> Add JBoss administrator"
    $JBOSS_HOME/bin/add-user.sh --silent=true $WILDFLY_USER $WILDFLY_PASS

    # Configure datasource
    echo "=> Create datasource: '${DATASOURCE}'"
    sed -i "/<drivers>/i\\
                    <datasource jndi-name=\"${DATASOURCE}\" pool-name=\"${DB_NAME}Pool\" enabled=\"true\" jta=\"true\" use-java-context=\"true\">\\
                        <connection-url>jdbc:mysql://${DB_URI}/${DB_NAME}</connection-url>\\
                        <driver>mysql</driver>\\
                        <pool>\\
                            <max-pool-size>25</max-pool-size>\\
                        </pool>\\
                        <security>\\
                            <user-name>${DB_USER}</user-name>\\
                            <password>${DB_PASS}</password>\\
                        </security>\\
                    </datasource>\\
    " $JBOSS_HOME/standalone/configuration/standalone.xml
    sed -i "/<\\/drivers>/i\\
                        <driver name=\"mysql\" module=\"com.mysql\">\\
                            <xa-datasource-class>com.mysql.jdbc.jdbc2.optional.MysqlXADataSource</xa-datasource-class>\\
                        </driver>
    " $JBOSS_HOME/standalone/configuration/standalone.xml

    echo "=> Clean up"
    ## FIX for Error: WFLYCTL0056: Could not rename /opt/jboss/wildfly/standalone/configuration/standalone_xml_history/current...
    rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/* \
        $JBOSS_HOME/standalone/log/*
    unset WILDFLY_USER WILDFLY_PASS DB_NAME DB_USER DB_PASS DATASOURCE
    
    touch $JBOSS_HOME/.setup
fi

if [[ "$WILDFLY_DEBUG" = "true" ]]; then
    echo "=> Enable debug mode"
    sed -i "s/#JAVA_OPTS=\"\$JAVA_OPTS -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n\"/JAVA_OPTS=\"\$JAVA_OPTS -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n\"/" $JBOSS_HOME/bin/standalone.conf
fi
    
echo "=> Start JBoss AS"
# Boot JBoss AS in standalone mode and bind it to all interfaces
$JBOSS_HOME/bin/standalone.sh -b 0.0.0.0
