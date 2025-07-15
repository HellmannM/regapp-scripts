
## Check LDAP path in module.xml
- /opt/wildfly/latest/modules/system/layers/base/sun/jdk/main/module.xml
    add "<path name="com/sun/jndi/ldap/ext"/>"


## Start the server with own config
$ cp regapp.xml /opt/wildfly/latest/standalone/configuration/regapp.xml
$ standalone.sh -c regapp.xml

## Deploy JDBC4 compliant driver
$ jboss-cli.sh --connect --commands=deploy\ /usr/share/java/postgresql-jdbc.jar

Values used in modified standalone-full-ha.xml
- Datasource:
    db-host: localhost
    password: secret

- Mail server:
    host: localhost (as mail relay)
    port: 25

## add wildfly management user
$ add-user.sh

## deploy app
$ jboss-cli.sh --connect --command=deploy\ ./regapp/bwreg-ear/target/bwreg-2.8.3.ear
alternatvely manage in browser and navigate to
http://localhost:9990


#TODO
# edit pg_hba.conf file to allow authentication via md5 for regapp-user from
# your host, which is running the application.

#TODO
# consider enabling pool constraints and checking mechanisms. More detailed
# instructions on datasources can be found on the Wildfly homepage:
# DataSource configuration
# https://docs.wildfly.org/19/wildscribe/subsystem/datasources/index.html


## access deployed app
http://localhost:8080
