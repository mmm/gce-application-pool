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
  num_app_servers_per_zone = 3
  image = "ubuntu-os-cloud/ubuntu-2004-lts"
  #image = "centos-cloud/centos-7"
  #image = "centos-cloud/centos-8"
}

resource "google_compute_instance_template" "uig_app_server_template" {
  name_prefix  = "uig-app-server"
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

resource "google_compute_instance_from_template" "primary_zone_app_server" {
  count = local.num_app_servers_per_zone
  name = "primary-zone-app-server-${count.index}"
  zone = var.primary_zone

  source_instance_template = google_compute_instance_template.uig_app_server_template.id

  // Override fields from instance template
  labels = {
    my_key = "my_value"
  }
}

resource "google_compute_instance_from_template" "secondary_zone_app_server" {
  count = local.num_app_servers_per_zone
  name = "secondary-zone-app-server-${count.index}"
  zone = var.secondary_zone

  source_instance_template = google_compute_instance_template.uig_app_server_template.id

  // Override fields from instance template
  labels = {
    my_key = "my_value"
  }
}

resource "google_compute_instance_group" "primary_zone_uig" {
  name = "application-uig-primary-zone"
  zone = var.primary_zone

  instances = [ for instance in google_compute_instance_from_template.primary_zone_app_server: instance.self_link ]
}

resource "google_compute_instance_group" "secondary_zone_uig" {
  name = "application-uig-secondary-zone"
  zone = var.secondary_zone

  instances = [ for instance in google_compute_instance_from_template.secondary_zone_app_server: instance.self_link ]
}
