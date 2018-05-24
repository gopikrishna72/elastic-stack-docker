# https://github.com/elastic/apm-server-docker

FROM docker.elastic.co/apm/apm-server:6.2.2

USER root

COPY config/apm-server.yml /usr/share/apm-server/apm-server.yml
RUN chown apm-server /usr/share/apm-server/apm-server.yml

COPY certs/ /usr/share/apm-server/certs/
RUN chown apm-server /usr/share/apm-server/certs/*

USER apm-server

# a command for setting up default kibana dashboards:
# docker-compose exec -T apm_server apm-server setup --dashboards
