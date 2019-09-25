ARG BUILD_FROM
FROM $BUILD_FROM

ENV GOPATH /opt/go

COPY files/GeoIP.conf /usr/local/etc/

# Install dependencies
RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers geoip-dev openssl tar curl go git musl-dev \
  && apk add --no-cache python2-dev py-pip geoip \
  && go get -u github.com/quantumew/mustache-cli \
  && go get -u github.com/maxmind/geoipupdate2/cmd/geoipupdate \
  && cp $GOPATH/bin/* /usr/local/bin/ \
  && mkdir /usr/local/share/GeoIP \
  && ./usr/local/bin/geoipupdate \
  && rm -rf $GOPATH \
  && git clone https://github.com/furlongm/openvpn-monitor.git \
  && apk del --purge .build-dependencies

# Copy custom config
COPY ./files /openvpn-monitor

WORKDIR /openvpn-monitor
# Add generator script
RUN chmod a+x run.sh \
  && pip install openvpn-monitor gunicorn

ENTRYPOINT ["/openvpn-monitor/run.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80" "--bind", "172.30.32.2:8099"]
