#!/usr/bin/env bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Check deps #################################################################
source SCRIPTS_DIR/regapp-check-dependencies.sh

## Build RegApp ###############################################################
# clone repo
git clone https://gitlab.kit.edu/kit/reg-app/regapp.git --recursive
pushd regapp

# checkout latest tagged version
git checkout "$(git describe --tags $(git rev-list --tags --max-count=1))"

# build (needs internet connection)"
mvn clean package

# change profile if necessary with -P, e.g. `mvn -Ppord-wildfly clean package`
# Consider using a seperate build profile for your environment. You can specify
# this profile in your maven settings.xml
popd

## Setup postgres (create empty database) #####################################
su postgres
createuser -P regapp-user
createdb -O regapp-user regapp
exit

#TODO
# edit pg_hba.conf file to allow authentication via md5 for regapp-user from
# your host, which is running the application.

## Appserver ##################################################################
# Note: use JBoss CLI or the Webinterface to modify config once app server is running.
# initial configuration: edit standalone-full-ha.xml file directly

# deploy a JDBC4 compliant driver via jar deployment on CLI
/opt/wildfly/bin/jboss-cli.sh --connect
deploy /usr/share/java/postgresql-jdbc4.jar
quit
# add datasource
XML_FILE="standalone-full-ha.xml"
DB_HOST="localhost"
DB_PASSWORD="secret"
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
xmlstarlet ed --inplace \
    -N x="urn:jboss:domain:datasources:2.0" \
    -s '//x:subsystem/x:datasources' -t elem -n "new-ds" -v "" \
    --subnode '//x:subsystem/x:datasources/new-ds' -t xml -n . -v "$DATASOURCE_XML" \
    --delete '//x:subsystem/x:datasources/new-ds' \
    "$XML_FILE"

#TODO
# consider enabling pool constraints and checking mechanisms. More detailed
# instructions on datasources can be found on the Wildfly homepage:
# DataSource configuration
# https://docs.wildfly.org/19/wildscribe/subsystem/datasources/index.html

# configure e-mail server (email property must be bound to JNDI name java:/mail/bwIdmMail)
# use localhost as mail relay
MAIL_HOST="localhost"
MAIL_PORT="25"
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
# make sure we dont insert when script is run again
MAIL_EXISTS=$(xmlstarlet sel -N m="urn:jboss:domain:mail:1.1" \
  -t -v "count(//m:subsystem/m:mail-session[@jndi-name='java:/mail/bwIdmMail'])" "$XML_FILE")
SOCKET_EXISTS=$(xmlstarlet sel \
  -t -v "count(//socket-binding-group/outbound-socket-binding[@name='mail-smtp-bwidm'])" "$XML_FILE")
if [ "$MAIL_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -N m="urn:jboss:domain:mail:1.1" \
        -s '//m:subsystem' -t elem -n "new-mail-session" -v "" \
        --subnode '//m:subsystem/new-mail-session' -t xml -n . -v "$MAIL_XML"
        --delete '//m:subsystem/new-mail-session' \
        "$XML_FILE"
fi
if [ "$SOCKET_EXISTS" -eq 0 ]; then
    xmlstarlet ed --inplace \
        -s '//socket-binding-group' -t elem -n "new-binding" -v "" \
        --subnode '//socket-binding-group/new-binding' -t xml -n . -v "$SOCKET_XML"
        --delete '//socket-binding-group/new-binding' \
        "$XML_FILE"
fi

# JMS


