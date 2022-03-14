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

locals {
}

#data "terraform_remote_state" "network" {
#  backend = "gcs"
#  config = {
#    bucket  = var.state_bucket
#    prefix  = "terraform/network/state"
#  }
#}
data "google_compute_network" "private_network" {
  name = var.network
}

resource "google_sql_database_instance" "private" {
  name             = "private-master-instance"
  database_version = "POSTGRES_12"
  region           = var.region

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = false
      private_network = data.google_compute_network.private_network.id
    }
  }
  deletion_protection = false
}

#module "cloudsql-postgres-ha" {
  #source = "../../third_party/terraform-google-cloudsql"

  #general = {
    #name       = "mydatabase"
    #env        = "dev"
    #region     = var.region
    #db_version = "POSTGRES_9_6"
  #}

  #instance = {
    #zone              = "b"
    #availability_type = "REGIONAL"
  #}
#}
