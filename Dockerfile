FROM mcrouter/mcrouter

RUN apt-get update && apt-get install -y \
    wget \
    python-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ===============
# consul-template
# ===============
ENV CONSUL_TEMPLATE_VERSION 0.19.4

RUN wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tgz -O /tmp/consul-template.tgz \
    && tar xf /tmp/consul-template.tgz -C /usr/bin/ \
    && chmod +x /usr/bin/consul-template \
    && rm /tmp/consul-template.tgz

# ===============
# Python packages
# ===============

COPY requirements.txt /tmp/
RUN pip install -U pip
# A workaround to address https://github.com/docker/docker-py/issues/1054
# # and to make sure latest pip is being used, not from OS one
ENV PYTHONPATH="/usr/local/lib/python2.7/dist-packages:/usr/lib/python2.7/dist-packages"
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# ==========
# misc stuff
# ==========
LABEL vendor="Gluu Federation"

ENV GLUU_KV_HOST localhost
ENV GLUU_KV_PORT 8500
ENV GLUU_CT_LOG_LEVEL info

RUN mkdir -p /opt/scripts /opt/templates /etc/mcrouter
COPY templates/mcrouter.json.ctmpl /opt/templates/
COPY templates/mcrouter.json /etc/mcrouter/
COPY scripts /opt/scripts/

RUN chmod +x /opt/scripts/entrypoint.sh

EXPOSE 5000
ENTRYPOINT [""]
CMD ["/opt/scripts/wait-for-it", "/opt/scripts/entrypoint.sh"]
