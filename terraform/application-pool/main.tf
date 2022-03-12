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

locals {
  num_app_servers = 6
  image = "ubuntu-os-cloud/ubuntu-2004-lts"
  #image = "centos-cloud/centos-7"
  #image = "centos-cloud/centos-8"
}

resource "google_compute_instance_template" "app_server" {
  name_prefix  = "regional-app-server"
  machine_type = var.instance_type
  region       = var.region

  disk {
    boot = true
    source_image = local.image
    auto_delete = true
  }

  network_interface {
    network = var.network
    #access_config {
    #}
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  metadata_startup_script = file("provision-ubuntu.sh")

  service_account {
    #scopes = ["userinfo-email", "compute-ro", "storage-full"]
    scopes = ["cloud-platform"]  # too permissive for production
  }

  #lifecycle {
    #create_before_destroy = true
  #}
}

resource "google_compute_region_instance_group_manager" "regional_apps" {
  name               = "regional-app-server-mig"
  base_instance_name = "regional-app-server"
  region               = "us-central1"
  distribution_policy_zones = ["us-central1-c","us-central1-f"]
  target_size        = local.num_app_servers
  version {
    instance_template  = google_compute_instance_template.app_server.id
  }
}

#resource "google_compute_region_health_check" "tcp-region-health-check" {
  #name        = "tcp-region-health-check"
  #description = "Health check via tcp"

  #timeout_sec         = 1
  #check_interval_sec  = 1
  #healthy_threshold   = 4
  #unhealthy_threshold = 5

  #tcp_health_check {
    #port               = "5000"
    ##port_name          = "health-check-port"
    ##port_specification = "USE_NAMED_PORT"
    #request            = "ARE YOU HEALTHY?"
    #proxy_header       = "NONE"
    #response           = "I AM HEALTHY"
  #}
#}
