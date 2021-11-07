terraform {
  backend "s3" {
    bucket = "hands-on-cloud-terraform-remote-state-s3"
    key = "vpc-endpoints-multi-region-access-infrastructure.tfstate"
    region = "us-west-2"
    encrypt = "true"
  }
}
