#!/bin/bash
#
# Copyright 2020 Google LLC
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

set -x

yum -y install \
  redhat-lsb \
  fuse \
  fuse-devel \
  fuse-devel-static \
  gvfs-fuse \
  libfuse2

modprobe fuse

# some debug tooling
yum -y install \
  netcat \
  bind-utils \
  postgresql

# docker
yum -y install \
  yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker
systemctl enable docker
systemctl start docker

