#!/usr/bin/env bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Settings ####################################################################
XML_FILE="standalone-full-ha.xml"
DB_HOST="localhost"
DB_PASSWORD="secret"
MAIL_HOST="localhost"
MAIL_PORT="25"
MODULE_XML_FILE="modules/system/layers/base/sun/jdk/main/module.xml"

# Check files exist ###########################################################
if [ ! -f "$XML_FILE" ]; then
  echo "ERROR: $XML_FILE not found!"
  exit 1
fi
if [ ! -f "$MODULE_XML_FILE" ]; then
  echo "ERROR: $MODULE_XML_FILE not found!"
  exit 1
fi

#TODO
# edit pg_hba.conf file to allow authentication via md5 for regapp-user from
# your host, which is running the application.

# Deploy JDBC4 compliant driver ###############################################
/opt/wildfly/bin/jboss-cli.sh --connect
deploy /usr/share/java/postgresql-jdbc4.jar
quit

# add datasource ##############################################################
#TODO
DATASOURCE_XML=$(cat <<EOF
        <datasource jndi-name="java:/ds/bwidmDS" pool-name="bwidmDS" enabled="true" use-java-context="true">
            <connection-url>jdbc:postgresql://${DB_HOST}:5432/bwidm</connection-url>
            <driver>postgresql-jdbc4.jar</driver>
            <security>
                <user-name>bwidm-user</user-name>
                <password>${DB_PASSWORD}</password>
            </security>
        </datasource>
EOF
)
DATASOURCE_EXISTS=$(xmlstarlet sel -N ns="urn:jboss:domain:datasources:2.0" \
  -t -v "count(//ns:subsystem/ns:datasources/ns:datasource[@jndi-name='java:/ds/bwIdmDS'])" "$XML_FILE")
if [ "$DATASOURCE_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -N ns="urn:jboss:domain:datasources:2.0" \
        -s '//ns:subsystem/ns:datasources' -t elem -n "new-ds" -v "" \
        --subnode '//ns:subsystem/ns:datasources/new-ds' -t xml -n . -v "$DATASOURCE_XML" \
        --delete '//ns:subsystem/ns:datasources/new-ds' \
        "$XML_FILE"
fi

#TODO
# consider enabling pool constraints and checking mechanisms. More detailed
# instructions on datasources can be found on the Wildfly homepage:
# DataSource configuration
# https://docs.wildfly.org/19/wildscribe/subsystem/datasources/index.html

# configure e-mail server #####################################################
# (email property must be bound to JNDI name java:/mail/bwIdmMail)
# use localhost as mail relay
MAIL_XML=$(cat <<EOF
    <mail-session jndi-name="java:/mail/bwIdmMail" name="bwidm">
        <smtp-server outbound-socket-binding-ref="mail-smtp-bwidm"/>
    </mail-session>
EOF
)
SOCKET_XML=$(cat <<EOF
    <outbound-socket-binding name="mail-smtp-bwidm">
        <remote-destination host="${MAIL_HOST}" port="${MAIL_PORT}"/>
    </outbound-socket-binding>
EOF
)
MAIL_EXISTS=$(xmlstarlet sel -N ns="urn:jboss:domain:mail:1.1" \
  -t -v "count(//ns:subsystem/ns:mail-session[@jndi-name='java:/mail/bwIdmMail'])" "$XML_FILE")
SOCKET_EXISTS=$(xmlstarlet sel \
  -t -v "count(//socket-binding-group/outbound-socket-binding[@name='mail-smtp-bwidm'])" "$XML_FILE")
if [ "$MAIL_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -N ns="urn:jboss:domain:mail:1.1" \
        -s '//ns:subsystem' -t elem -n "new-mail-session" -v "" \
        --subnode '//ns:subsystem/new-mail-session' -t xml -n . -v "$MAIL_XML"
        --delete '//ns:subsystem/new-mail-session' \
        "$XML_FILE"
fi
if [ "$SOCKET_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -s '//socket-binding-group' -t elem -n "new-binding" -v "" \
        --subnode '//socket-binding-group/new-binding' -t xml -n . -v "$SOCKET_XML"
        --delete '//socket-binding-group/new-binding' \
        "$XML_FILE"
fi

# JMS #########################################################################
JMS_MAIL_QUEUE_XML=$(cat <<EOF
      <jms-queue name="bwIdmMailQueue">
        <entry name="queue/bwIdmMailQueue"/>
        <entry name="java:jboss/exported/jms/queue/bwIdmMailQueue"/>
      </jms-queue>
EOF
)
JMS_JOB_QUEUE_XML=$(cat <<EOF
      <jms-queue name="bwIdmAsyncJobQueue">
        <entry name="queue/bwIdmAsyncJobQueue"/>
        <entry name="java:jboss/exported/jms/queue/bwIdmAsyncJobQueue"/>
      </jms-queue>
EOF
)
JMS_MAIL_QUEUE_EXISTS=$(xmlstarlet sel -N ns="urn:jboss:domain:messaging:1.3" \
  -t -v "count(//ns:subsystem/ns:hornetq-server/ns:jms-destinations/jms-queue[@name='bwIdmMailQueue'])" "$XML_FILE")
JMS_JOB_QUEUE_EXISTS=$(xmlstarlet sel -N ns="urn:jboss:domain:messaging:1.3" \
  -t -v "count(//ns:subsystem/ns:hornetq-server/ns:jms-destinations/jms-queue[@name='bwIdmAsyncJobQueue'])" "$XML_FILE")
if [ "$JMS_MAIL_QUEUE_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -N ns="urn:jboss:domain:messaging:1.3" \
        -s '//ns:subsystem/ns:hornetq-server/ns:jms-destinations' -t elem -n "new-queue" -v "" \
        --subnode '//ns:subsystem/ns:hornetq-server/ns:jms-destinations/new-queue' -t xml -n . -v "$JMS_MAIL_QUEUE_XML"
        --delete '//ns:subsystem/new-queue' \
        "$XML_FILE"
fi
if [ "$JMS_JOB_QUEUE_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -N ns="urn:jboss:domain:messaging:1.3" \
        -s '//ns:subsystem/ns:hornetq-server/ns:jms-destinations' -t elem -n "new-queue" -v "" \
        --subnode '//ns:subsystem/ns:hornetq-server/ns:jms-destinations/new-queue' -t xml -n . -v "$JMS_JOB_QUEUE_XML"
        --delete '//ns:subsystem/new-queue' \
        "$XML_FILE"
fi


# Allow TLS LDAP connections ##################################################
LDAP_PATH="com/sun/jndi/ldap/ext"
MODULE_EXISTS=$(xmlstarlet sel -t -v "count(/module/resources/path[@name='$LDAP_PATH'])" "$MODULE_XML_FILE")
if [ "$JMS_JOB_QUEUE_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -s "/module/resources" -t elem -n "newpath" -v "" \
        --insert "/module/resources/newpath" --type attr -n "name" -v "$LDAP_PATH" \
        --rename "/module/resources/newpath" -v "path" \
        "$MODULE_XML_FILE"
fi


