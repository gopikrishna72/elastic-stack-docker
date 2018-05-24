#!/bin/bash
# The script removes old (3 day) indexes from the elasticsearch for saving some space
# because APM generates a LOT of data (500mb from rarely used service per day - that's fucj)
# add this to crontab:
# 0 0 * * * cd /docker/compose/dir && docker-compose exec -T elasticsearch /usr/local/bin/flush-old-indexes.sh > some_log.log


INDEX_NAME=apm-6.2.2-`date +%Y.%m.%d -d "3 day ago"`

# TODO: use env vars or secrets
curl -XDELETE -u admin:admin 'localhost:9200/${INDEX_NAME}?format=json&pretty'
