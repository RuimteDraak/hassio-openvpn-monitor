ARG BUILD_FROM
FROM $BUILD_FROM

ENV GOPATH /opt/go

COPY files/GeoIP.conf /usr/local/etc/

# Install dependencies
RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers openssl tar curl git musl-dev \
  && apk add --no-cache python2-dev py-pip \
  && apk add --update npm \
  && npm install mustache -g \
  && mkdir -p /usr/local/share/GeoIP/ \
  && wget -O - https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz | tar -C /usr/local/share/GeoIP/ --strip-components=1 -zxvf - \
  && git clone https://github.com/furlongm/openvpn-monitor.git \
  && apk del --purge .build-dependencies

# Copy custom config
COPY ./files /openvpn-monitor

WORKDIR /openvpn-monitor
# Add generator script
RUN chmod a+x run.sh \
  && pip install openvpn-monitor gunicorn

ENTRYPOINT ["/openvpn-monitor/run.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80", "--bind", "0.0.0.0:8099"]
