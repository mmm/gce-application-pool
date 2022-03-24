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
  name        = "autohealing-health-check"
  description = "Health check via tcp"

  timeout_sec         = 30
  check_interval_sec  = 300
  healthy_threshold   = 1
  unhealthy_threshold = 10

  tcp_health_check {
    port               = "80"
  }
}

resource "google_compute_region_instance_group_manager" "regional_mig" {
  name               = "application-regional-mig"
  base_instance_name = "regional-mig-app-server"
  region               = "us-central1"
  distribution_policy_zones = ["us-central1-c","us-central1-f"]
  #target_size        = local.num_app_servers
  version {
    instance_template  = google_compute_instance_template.mig_app_server_template.id
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "application_autoscaler" {
  name   = "application-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.regional_mig.id

  autoscaling_policy {
    max_replicas    = local.num_app_servers
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
