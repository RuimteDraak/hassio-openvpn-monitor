ARG BUILD_FROM
FROM $BUILD_FROM

ENV GOPATH /opt/go

COPY GeoIP.conf /usr/local/etc/

# Install dependencies
RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers geoip-dev openssl tar curl go git musl-dev \
  && apk add --no-cache python2-dev py-pip \
  && go get -u github.com/quantumew/mustache-cli \
  && go get -u github.com/maxmind/geoipupdate2/cmd/geoipupdate \
  && cp $GOPATH/bin/* /usr/local/bin/ \
  && mkdir /usr/local/share/GeoIP \
  && ./usr/local/bin/geoipupdate \
  && rm -rf $GOPATH 

# Copy app
RUN git clone https://github.com/furlongm/openvpn-monitor.git
COPY . /openvpn-monitor

# Prepare config
COPY server.mustache /templates/

WORKDIR /openvpn-monitor
# Add generator script
COPY run.sh /
RUN chmod a+x run.sh

# Prepare environment
RUN pip install openvpn-monitor gunicorn
RUN apk add --no-cache geoip

EXPOSE 80

ENTRYPOINT ["/openvpn-monitor/run.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
