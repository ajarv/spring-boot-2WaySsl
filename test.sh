#!/bin/bash
set -x
app_name=two-way
git_repo=https://aplsiscmp001.sempra.com/avashist/spring-boot-2WaySsl.git
project_display_name="$(echo ${USER} ${app_name}|sed -r 's/(^|-)(\w)/\U\2/g')"
project_name="${USER}-${app_name}"
app_hostname="${app_name}.dev.10.29.203.12.nip.io"
keystorejks=keystore.jks

password=$(echo Z2hhbmdlaXQK | base64 -d)
rm -rf ${keystorejks}
keytool -genkey -keyalg RSA -dname "cn=Mount San Jacinto, ou= DevOps, o=efficient snob, c=US" -alias mt-san-jacinto -keystore ${keystorejks} -storepass ${password} -keypass ${password} -validity 360 -keysize 2048 -ext "SAN=dns:two-way-ssl.sdgesi.team.io"


oc delete project ${project_name}
sleep 20

oc new-project ${project_name} --display-name "${project_display_name}"

oc delete secret ssl-truststore ssl-truststore-password
oc create secret generic ssl-keystore --from-file=${keystorejks} 
oc create secret generic ssl-keystore-password --from-literal=password=${password}

oc new-app spring-app.yaml -p SOURCE_REPOSITORY_URL=${git_repo} -p APPLICATION_DOMAIN="${app_hostname}" -p APP_NAME=${app_name} 

sleep 60
curl -ikv -X GET "https://${app_hostname}/greeting" -H "accept: */*"
