#!/bin/bash

# wait till elasticsearch is started
es_url=http://${PING_USERNAME}:${PING_PASSWORD}@localhost:9200

until curl -s $es_url -o /dev/null; do
    echo "SearchGuard setup is waiting for ElasticSearch start 5 more seconds..."
    sleep 5
done

sleep 5

echo "Elastic is started. Launching SearchGuard setup..."
/usr/share/elasticsearch/bin/init_sg.sh
