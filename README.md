# Automating Access To Multi-Region VPC Endpoints using Terraform

This is a demo repository for the [Automating Access To Multi-Region VPC Endpoints using Route53 Resolver And Terraform](https://hands-on.cloud/automating-access-to-multi-region-vpc-endpoints-using-terraform/) article.

This module sets up the following AWS services:

* VPC
* EC2
* S3
* Route53

![VPC architecture](1_infrastructure/img/architecture.png)

VPC Endpoint resolution workflow:

![VPC Endpoint resolution workflow](1_infrastructure/img/vpc-endpoint-resolution.png)

Apply the following Terraform modules in order to build end-to-end infrastructure described in the article.

Every Terraform module contains its own README file and architecture diagram.
