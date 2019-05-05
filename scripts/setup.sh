#/bin/ash
confdir="${PWD}/config"
chown 1000 -R "$confdir"
find "$confdir" -type f -name "*.keystore" -exec chmod go-wrx {} \;
find "$confdir" -type f -name "*.yml" -exec chmod go-wrx {} \;

if [ -f "$confdir/elasticsearch/elasticsearch.keystore" ]; then
    rm "$confdir/elasticsearch/elasticsearch.keystore"
fi

PW=$(openssl rand -base64 16;)
ELASTIC_PASSWORD="${ELASTIC_PASSWORD:-$PW}"
export ELASTIC_PASSWORD

# setup elasticsearch (and system passwords)
docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_elasticsearch 

# setup kibana (and system passwords)
docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_kibana

# setup logstash
docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_logstash

# setup beats
docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_auditbeat 

docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_filebeat

docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_heartbeat

docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_metricbeat

docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_packetbeat

docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_journalbeat

# setup apm server
docker-compose -f docker-compose.yml -f docker-compose.setup.yml up setup_apm_server

printf "Setup completed successfully. To start the stack please run:\n\t docker-compose up -d\n"
printf "\nIf you wish to remove the setup containers please run:\n\tdocker-compose -f docker-compose.yml -f docker-compose.setup.yml down --remove-orphans\n"
printf "\nYou will have to re-start the stack after removing setup containers.\n"
printf "\nYour 'elastic' user password is: $ELASTIC_PASSWORD\n"
