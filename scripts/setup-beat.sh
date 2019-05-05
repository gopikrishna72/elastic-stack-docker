#!/bin/bash

set -euo pipefail

beat=$1

until curl -s "http://kibana:5601/login" | grep "Loading Kibana" > /dev/null; do
	  echo "Waiting for kibana..."
	  sleep 1
done

cacert=/usr/share/${beat}/certs/ca/ca.crt
# Wait for ca file to exist before we continue. If the ca file doesn't exist
# then something went wrong.
while [ ! -f $cacert ]
do
  sleep 2
done
#ls -la $cacert

es_url=https://elasticsearch:9200
# Wait for Elasticsearch to start up before doing anything.
while [[ "$(curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $cacert -s -o /dev/null -w '%{http_code}' $es_url)" != "200" ]]; do 
    sleep 5 
done

# Set the password for the beats_system user.
# REF: https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#set-built-in-user-passwords
until curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $cacert -s -H 'Content-Type:application/json' \
     -XPUT $es_url/_security/user/beats_system/_password \
     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
do
    sleep 2
    echo "Waiting for elasticsearch..."
done

chmod u=rw,go=r,o=r /usr/share/$beat/$beat.yml
#chown root:${beat} /usr/share/${beat}/${beat}.yml
chown root:1000 /usr/share/${beat}/${beat}.yml
#chown root:root /usr/share/${beat}/${beat}.yml
ls -la /usr/share/$beat/$beat.yml
#chown root:root /usr/share/${beat}/${beat}.yml

echo "Creating keystore..."
# create beat keystore
$beat keystore create --force
chown root:root /usr/share/${beat}/data/beats.keystore

echo "adding ELASTIC_PASSWORD to keystore..."
echo "$ELASTIC_PASSWORD" | ${beat} --strict.perms=false keystore add ELASTIC_PASSWORD --stdin
${beat} --strict.perms=false keystore list

echo "Setting up dashboards..."
# Load the sample dashboards for the Beat.
# REF: https://www.elastic.co/guide/en/beats/metricbeat/master/metricbeat-sample-dashboards.html
${beat} --strict.perms=false setup -v

echo "Copy keystore to ./config dir"
cp /usr/share/$beat/data/beats.keystore /config/$beat/beats.keystore
chown 1000:1000 /config/$beat/beats.keystore
