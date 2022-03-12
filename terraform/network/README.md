# Network


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

