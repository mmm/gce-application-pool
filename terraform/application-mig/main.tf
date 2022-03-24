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

resource "google_compute_instance_template" "mig_app_server_template" {
  name_prefix  = "regional-mig-app-server"
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
  
  tags = ["allow-health-check"]
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/healthz"
    port         = "8080"
  }
}

resource "google_compute_region_health_check" "autohealing" {
  name        = "autohealing-health-check"
  description = "Health check via tcp"

  timeout_sec         = 30
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  tcp_health_check {
    port               = "80"
  }
}

resource "google_compute_region_instance_group_manager" "regional_mig" {
  name               = "application-regional-mig"
  base_instance_name = "regional-mig-app-server"
  region               = "us-central1"
  distribution_policy_zones = ["us-central1-c","us-central1-f"]
  target_size        = local.num_app_servers
  version {
    instance_template  = google_compute_instance_template.mig_app_server_template.id
  }
  auto_healing_policies {
    health_check      = google_compute_region_health_check.autohealing.id
    initial_delay_sec = 300
  }
}
