FROM debian:stretch-slim
LABEL maintainer="Phil Hawthorne <me@philhawthorne.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Default versions
ENV INFLUXDB_VERSION=2.3.0
ENV GRAFANA_VERSION=9.0.6

# Grafana database type
ENV GF_DATABASE_TYPE=sqlite3

# Config influxdb
ENV INFLUXD_CONFIG_PATH /etc/influxdb/config.toml

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

WORKDIR /root

# Clear previous sources
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" && \
  case "${dpkgArch##*-}" in \
  amd64) ARCH='amd64';; \
  arm64) ARCH='arm64';; \
  armhf) ARCH='armhf';; \
  armel) ARCH='armel';; \
  *)     echo "Unsupported architecture: ${dpkgArch}"; exit 1;; \
  esac && \
  rm /var/lib/apt/lists/* -vf \
  # Base dependencies
  && apt-get -y update \
  && apt-get -y dist-upgrade \
  && apt-get -y install \
  apt-utils \
  openssh-server \
  ca-certificates \
  curl \
  git \
  htop \
  libfontconfig \
  nano \
  net-tools \
  supervisor \
  wget \
  gnupg \
  && sed -i 's/#PermitRootLogin\sprohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PermitEmptyPasswords\sno/PermitEmptyPasswords yes/' /etc/ssh/sshd_config \
  &&  mkdir -p /run/sshd \
  && echo 'root:root' | chpasswd \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
  && apt-get install -y nodejs \
  && mkdir -p /var/log/supervisor \
  && rm -rf .profile \
  # Install InfluxDB
  && wget https://dl.influxdata.com/influxdb/releases/influxdb2-${INFLUXDB_VERSION}-${ARCH}.deb \
  && dpkg -i influxdb2-${INFLUXDB_VERSION}-${ARCH}.deb \
  && rm influxdb2-${INFLUXDB_VERSION}-${ARCH}.deb \
  # Install Grafana
  && wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_${ARCH}.deb \
  && dpkg -i grafana_${GRAFANA_VERSION}_${ARCH}.deb \
  && rm grafana_${GRAFANA_VERSION}_${ARCH}.deb \
  # Cleanup
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure Supervisord and base env
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY bash/profile .profile

# Configure InfluxDB
COPY influxdb/config.toml /etc/influxdb/config.toml

# Configure Grafana
COPY grafana/grafana.ini /etc/grafana/grafana.ini

EXPOSE 22 3003 8086

VOLUME [ "/var/lib/influxdb", "/var/lib/grafana" ]

COPY run.sh /run.sh
RUN ["chmod", "+x", "/run.sh"]
CMD ["/run.sh"]
