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
  application_port = "80"
}

#data "terraform_remote_state" "network" {
  #backend = "gcs"
  #config = {
    #bucket  = var.state_bucket
    #prefix  = "terraform/network/state"
  #}
#}
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

#data "terraform_remote_state" "application_pool" {
  #backend = "gcs"
  #config = {
    #bucket  = var.state_bucket
    #prefix  = "terraform/application-pool/state"
  #}
#}
data "terraform_remote_state" "application_uig" {
  backend = "local"

  config = {
    path = "../application-pool/terraform.tfstate"
  }
}

resource "google_compute_region_health_check" "regional_tcp_80_health_check" {
  name               = "regional-tcp-80-health-check"
  region             = var.region

  tcp_health_check {
    port = 80
  }

  log_config {
    enable = true
  }
}

resource "google_compute_region_backend_service" "application_uig_backend_service" {
  name = "regional-uig-backend-service"
  region = var.region
  protocol = "TCP"
  #load_balancing_scheme = "INTERNAL_MANAGED"
  #locality_lb_policy = "ROUND_ROBIN"
  session_affinity = "NONE"

  health_checks = [google_compute_region_health_check.regional_tcp_80_health_check.id]

  backend {
    group = data.terraform_remote_state.application_uig.outputs.primary_zone_uig_id
    #balancing_mode = "UTILIZATION"
  }
  backend {
    group = data.terraform_remote_state.application_uig.outputs.secondary_zone_uig_id
    #balancing_mode = "UTILIZATION"
  }
}

resource "google_compute_forwarding_rule" "google_compute_uig_forwarding_rule" {
  name                  = "l4-ilb-uig-forwarding-rule"
  backend_service       = google_compute_region_backend_service.application_uig_backend_service.id
  region                = var.region
  ip_address            = data.terraform_remote_state.network.outputs.ilb_head_address
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  #network               = google_compute_network.ilb_network.id
  #subnetwork            = google_compute_subnetwork.ilb_subnet.id
}


resource "google_compute_firewall" "allow_health_check" {
  name        = "allow-health-check"
  network     = var.network

  allow {
    protocol  = "tcp"
    ports     = ["80", "5000"]
  }

  source_ranges = [ "130.211.0.0/22","35.191.0.0/16" ] # GCP Healthcheck sources

  target_tags = ["allow-health-check"]
}
