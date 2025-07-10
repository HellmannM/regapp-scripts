
## Check LDAP path in module.xml
- /opt/wildfly/latest/modules/system/layers/base/sun/jdk/main/module.xml
    add "<path name="com/sun/jndi/ldap/ext"/>"


## Deploy JDBC4 compliant driver
$ standalone.sh &
$ jboss-cli.sh --connect
$ deploy /usr/share/java/postgresql-jdbc.jar
$ quit


## Start the server with own config
$ standalone.sh -c standalone-full-ha.xml

Values used in modified standalone-full-ha.xml
- Datasource:
    db-host: localhost
    password: secret

- Mail server:
    host: localhost (as mail relay)
    port: 25


#TODO
# edit pg_hba.conf file to allow authentication via md5 for regapp-user from
# your host, which is running the application.

#TODO
# consider enabling pool constraints and checking mechanisms. More detailed
# instructions on datasources can be found on the Wildfly homepage:
# DataSource configuration
# https://docs.wildfly.org/19/wildscribe/subsystem/datasources/index.html
