## Spring Boot Sample App to demo 2 Way SSL


### Clenup 

```sh
oc delete project ${project_name}
sleep 10
```
### Create Project
```sh
oc new-project ${project_name} --display-name "${project_display_name}"
```

### Create a self signed cert

```sh
password=$(echo Y2hhbmdlaXQK | base64 -d)

keytool -genkey -keyalg RSA -dname "cn=Mount San Jacinto, ou= DevOps, o=efficient snob, c=US" -alias mt-san-jacinto -keystore keystore.jks -storepass ${password} -keypass ${password} -validity 360 -keysize 2048 -ext "SAN=dns:two-way-ssl.sdgesi.team.io"
```

### Create secrets

```sh
oc delete secret ssl-truststore ssl-truststore-password
oc create secret generic ssl-keystore --from-file=keystore.jks 
oc create secret generic ssl-keystore-password --from-literal=password=${password}
```

### App Settings

```sh
app_name=two-way
git_repo=https://github.com/ajarv/spring-boot-2WaySsl.git
project_display_name="$(echo ${USER} ${app_name}|sed -r 's/(^|-)(\w)/\U\2/g')"
project_name="${USER}-${app_name}"
app_hostname="${app_name}.${LB_VIP}.nip.io"
```


<strong>Option 1</strong> If you want to deploy the applicaiton in a non secure way 
```sh 
oc new-app redhat-openjdk18-openshift:1.1~${git_repo} --name=${app_name} --build-env=GIT_SSL_NO_VERIFY=true
oc create route passthrough "secure-passthru-${app_name}" --service svc/${app_name} --hostname=${app_hostname} --port=8443
#oc expose svc/${app_name} --hostname=${app_hostname}
curl -k -X GET "https://${app_hostname}/greeting" -H "accept: */*"
```

<strong>Option 2</strong> Use the deployment template


```sh 
oc new-app spring-app.yaml -p SOURCE_REPOSITORY_URL=${git_repo} -p APPLICATION_DOMAIN="${app_hostname}" -p APP_NAME=${app_name} 
sleep 40
curl -ivk -X GET "https://${app_hostname}/greeting" -H "accept: */*"

```

