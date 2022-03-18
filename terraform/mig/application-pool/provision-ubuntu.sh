#!/bin/bash
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export DEBIAN_FRONTEND=noninteractive

apt-get -qq update
apt-get -qqy install \
  lsb \
  fuse \
  gvfs-fuse \
  libfuse2 \
  libfuse-dev

modprobe fuse

# install some debugging utils
apt-get -qqy install \
  dnsutils \
  netcat-openbsd \
  net-tools \
  sysstat \
  iperf3

# install docker
# the ubuntu maintained version is good enough
apt-get -qqy install \
  docker.io \
  docker-compose
echo '*;*;*;Al0000-2400;docker' >> /etc/security/group.conf

# set up heater
mkdir -p /opt/heater
cat <<- 'EOS' > /opt/heater/docker-compose.yml
version: "3"
services:
  heater:
    image: markmims/heater
    network_mode: host
    ports:
      - "80:80"
EOS

# pull some images
docker-compose -f /opt/heater/docker-compose.yml pull
docker-compose -f /opt/heater/docker-compose.yml up -d


