#!/bin/bash

es_url="https://localhost:9200"
ELASTIC_PASSWORD="IUgSCwpr693bKX3xqpC8Og=="

curl -u "elastic:${ELASTIC_PASSWORD}" -k -s -H 'Content-Type:application/json' \
     -XPUT $es_url/_security/user/kibana/_password \
     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
