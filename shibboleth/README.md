### run ldap
```
docker run -d --name openldap --network shibdev \
  -e LDAP_DOMAIN=dev.local \
  -e LDAP_ADMIN_PASSWORD=admin \
  -p 389:389 -p 636:636 \
  docker.io/osixia/openldap:1.5.0
```

### Pick hostname
Pick a dev FQDN for cookies + SAML sanity, e.g.:
- IdP: idp.dev.local
- SP (RegApp): regapp.dev.local

Map them to your machine/ingress IP:
```sh
sudo bash -c 'cat >>/etc/hosts <<EOF
127.0.0.1  idp.dev.local regapp.dev.local
EOF'
```


### Generate IdP config tree
```sh
mkdir -p $PWD/shibdev
pushd $PWD/shibdev
# run interactively and answer prompts:
# IdP hostname: idp.dev.local
# entityID: https://idp.dev.local/idp/shibboleth
# scope: dev.local
# ldap://openldap:389
# base dn: dc=dev,dc=local
# dn: cn=admin,dc=dev,dc=local
podman run --rm -it \
  --network shibdev \
  -e BUILD_ENV=LINUX \
  -v "$PWD:/output:Z" \
  i2incommon/shibbidp_configbuilder_container:latest
popd
```


### Create test users (no LDAP): htpasswd file
```sh
mkdir -p $PWD/shibdev/idp/conf/authn
htpasswd -c -B $PWD/shibdev/idp/conf/authn/htpasswd.txt alice
htpasswd    -B $PWD/shibdev/idp/conf/authn/htpasswd.txt bob
```

edit conf/authn/password-authn-config.xml and set:
```xml
<util:list id="shibboleth.authn.Password.Validators">
  <bean parent="shibboleth.HTPasswdCredentialValidator"
        p:resource="%{idp.home}/conf/authn/htpasswd.txt" />
</util:list>
```

enable password module from inside the IdP home (often /opt/shibboleth-idp in the container)
```sh
bin/module.sh -t idp.authn.Password || bin/module.sh -e idp.authn.Password
```


### fake attribs
with StaticDataConnector + AttributreDefinitions in `conf/attribute-resolver.xml`
- eduPersonPrincipalName (alice@dev.local)
- mail
- displayName
- givenName
- sn
- eduPersonScopedAffiliation (member@dev.local)

### load RegApp SP metadata into the IdP
download the metadata XML (http://localhost:8443/saml/sp/metadata/TestSP)
place it into the IdPs `metadata/` directory (`metadata/regapp.xml`
add a filesystem metadata provider entry pointing at it in `conf/metadata-providers.xml`


### run IdP
```
docker run -d --name shib-idp \
  -p 8443:8443 \
  -v "$PWD/idp:/opt/shibboleth-idp:Z" \
  i2incommon/shib-idp:5.1.6_20251106_rocky9_multiarch
```
check what is listening:
```
docker port shib-idp
docker logs -f shib-idp
```
check https://idp.dev.local:8443/idp/shibboleth (or port that `docker port` shows)




