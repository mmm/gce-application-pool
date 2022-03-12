# Application Pool


## Usage

### Project

Be sure to run

    export GOOGLE_CLOUD_PROJECT=<your-project-name-here>

in the shell before running terraform.

### State

Create a bucket we'll use for state:

    gsutil mb gs://<your-bucket-name-here>/

so, for example

    gsutil mb gs://my-fancy-bucket/


### Terraform

Then

    terraform init -backend-config="bucket=<your-bucket-name-here>"


# links

Some useful links:

- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager
- https://cloud.google.com/compute/docs/instance-groups/distributing-instances-with-regional-instance-groups#selectingzones
- https://cloud.google.com/compute/docs/instance-groups/configuring-stateful-disks-in-migs


