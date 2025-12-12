
entityID: ask/register uri with uni/dfn-aai? e.g. https://regapp.uni-koeln.de/sp
using hostname for testing
http://regapptestmachine:8080/sp
since we access website with localhost:8080 we need to use that as uri as well?
http://localhost:8080/sp


# generate key and self-signed cert (should be replaced with cert signed by dfn-pki)
openssl genrsa -out regapp-sp.key 2048
openssl req -new -key regapp-sp.key -out regapp-sp.csr \
  -subj "/C=DE/ST=NRW/L=Cologne/O=University of Cologne/OU=IT/CN=regapp.uni-koeln.de"
openssl x509 -req -days 1825 -in regapp-sp.csr -signkey regapp-sp.key -out regapp-sp.crt


after testing:
- register it with DFN-AAI (they’ll add the SP to metadata).
- They may require a DFN-PKI certificate signed by their CA (in which case the CSR above will be useful).


edit config:
- Assertion Consumer Endpoint: "/Shibboleth.sso/SAML2/POST"
- ECP Endpoint: "/Shibboleth.sso/SAML2/ECP"
- hostname: regapp.dev.local

### add IDPs
list federations -> add federation
- name: eduGAIN
- url: https://mds.edugain.org/edugain-v2.xml
- check fetch IDPs
- save and edit
- entity category: http://aai.dfn.de/category/bwidm-member
  http://aai.dfn.de/category/highmeducation-member
  TODO create new? hpcnrw?
- poll now


### Update Federation Data
- create job class
Name: choose freely
Job class: edu.kit.scc.webreg.job.UpdateAllFederationMetadata
Single node: Yes
Properties: none
- create schedule and activate

### ldap
- https://gitlab.kit.edu/kit/reg-app/regapp/-/wikis/registerbeans/LdapRegisterWorkflow
