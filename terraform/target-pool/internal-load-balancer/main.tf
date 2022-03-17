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
    path = "../../network/terraform.tfstate"
  }
}

#data "terraform_remote_state" "application_pool" {
  #backend = "gcs"
  #config = {
    #bucket  = var.state_bucket
    #prefix  = "terraform/application-pool/state"
  #}
#}
data "terraform_remote_state" "application_target_pool" {
  backend = "local"

  config = {
    path = "../application-pool/terraform.tfstate"
  }
}

resource "google_compute_region_health_check" "default" {
  name               = "heater-health-check"
  region             = var.region

  http_health_check {
    port = 80
  }
}

resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  name                  = "l4-ilb-forwarding-rule"
  target                = data.terraform_remote_state.application_target_pool.outputs.target_pool_id
  region                = var.region
  ip_address            = data.terraform_remote_state.network.outputs.ilb_head_address
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  #network               = google_compute_network.ilb_network.id
  #subnetwork            = google_compute_subnetwork.ilb_subnet.id
}
