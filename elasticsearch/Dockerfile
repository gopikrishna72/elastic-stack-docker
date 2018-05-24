# https://github.com/elastic/elasticsearch-docker

FROM docker.elastic.co/elasticsearch/elasticsearch:6.2.2

ADD config/sg/ /usr/share/elasticsearch/config/sg/
ADD bin/ /usr/share/elasticsearch/bin/

COPY bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY bin/setup-searchguard.sh /usr/local/bin/setup-searchguard.sh
COPY bin/flush-old-indexes.sh /usr/local/bin/flush-old-indexes.sh

RUN chown elasticsearch /usr/local/bin/docker-entrypoint.sh && \
    chgrp 0 /usr/local/bin/docker-entrypoint.sh && \
    chmod 0775 /usr/local/bin/docker-entrypoint.sh

RUN chown elasticsearch /usr/local/bin/setup-searchguard.sh && \
    chgrp 0 /usr/local/bin/setup-searchguard.sh && \
    chmod 0775 /usr/local/bin/setup-searchguard.sh

RUN chown elasticsearch /usr/local/bin/flush-old-indexes.sh && \
    chgrp 0 /usr/local/bin/flush-old-indexes.sh && \
    chmod 0775 /usr/local/bin/flush-old-indexes.sh

# Search Guard plugin
# https://github.com/floragunncom/search-guard/wiki
RUN elasticsearch-plugin install --batch com.floragunn:search-guard-6:6.2.2-22.0 && \
    chmod +x plugins/search-guard-6/tools/*.sh && \
    chown -R elasticsearch config/sg/ && \
    chmod -R go= config/sg/

# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu
