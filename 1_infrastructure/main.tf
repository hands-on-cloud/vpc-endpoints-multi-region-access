data "aws_caller_identity" "current" {}

locals {
  prefix      = "vpc-endpoints-multi-region-access"

  aws_account = data.aws_caller_identity.current.account_id

  common_tags = {
    Project         = local.prefix
    ManagedBy       = "Terraform"
  }

  vpcs = {
    us-east-1 = {
      cidr = "10.0.0.0/16"
      region = "us-east-1"
      name = "${local.prefix}-us-east-1"
      azs = ["us-east-1a", "us-east-1b"]
      private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
    }

    us-east-2 = {
      cidr = "10.1.0.0/16"
      region = "us-east-2"
      name = "${local.prefix}-us-east-2"
      azs = ["us-east-2a", "us-east-2b"]
      private_subnets = ["10.1.0.0/24", "10.1.1.0/24"]
    }

    us-west-2 = {
      cidr = "10.2.0.0/16"
      region = "us-west-2"
      name = "${local.prefix}-us-west-2"
      azs = ["us-west-2a", "us-west-2b"]
      public_subnets = ["10.2.10.0/24", "10.2.11.0/24"]
      private_subnets = ["10.2.0.0/24", "10.2.1.0/24"]
    }
  }
}

module "vpc_us_east_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name = local.vpcs.us-east-1.name
  cidr = local.vpcs.us-east-1.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs             = local.vpcs.us-east-1.azs
  private_subnets = local.vpcs.us-east-1.private_subnets

  tags = local.common_tags
}

module "vpc_us_east_2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name = local.vpcs.us-east-2.name
  cidr = local.vpcs.us-east-2.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs             = local.vpcs.us-east-2.azs
  private_subnets = local.vpcs.us-east-2.private_subnets

  tags = local.common_tags

  providers = {
    aws = aws.us-east-2
  }
}

module "vpc_us_west_2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  name = local.vpcs.us-west-2.name
  cidr = local.vpcs.us-west-2.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs             = local.vpcs.us-west-2.azs
  public_subnets  = local.vpcs.us-west-2.public_subnets
  private_subnets = local.vpcs.us-west-2.private_subnets

  tags = local.common_tags

  providers = {
    aws = aws.us-west-2
  }
}

# Peering connection: us_west-2 <-> us_east_1

resource "aws_vpc_peering_connection" "us_west-2-us_east_1" {
  vpc_id        = module.vpc_us_west_2.vpc_id
  peer_vpc_id   = module.vpc_us_east_1.vpc_id
  peer_owner_id = local.aws_account
  peer_region   = "us-east-1"
  auto_accept   = false

  tags = local.common_tags

  provider = aws.us-west-2
}

resource "aws_vpc_peering_connection_accepter" "us_east_1-us_west-2" {
  provider                  = aws
  vpc_peering_connection_id = aws_vpc_peering_connection.us_west-2-us_east_1.id
  auto_accept               = true

  tags = local.common_tags
}

resource "aws_route" "us_west-2-us_east_1" {
  count = length(module.vpc_us_west_2.private_route_table_ids)
  route_table_id = module.vpc_us_west_2.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc_us_east_1.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_west-2-us_east_1.id

  provider = aws.us-west-2
}

resource "aws_route" "us_east_1-us_west-2" {
  count = length(module.vpc_us_east_1.private_route_table_ids)
  route_table_id = module.vpc_us_east_1.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc_us_west_2.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.us_east_1-us_west-2.id
}

# Peering connection: us_west-2 <-> us_east_2

resource "aws_vpc_peering_connection" "us_west-2-us_east_2" {
  vpc_id        = module.vpc_us_west_2.vpc_id
  peer_vpc_id   = module.vpc_us_east_2.vpc_id
  peer_owner_id = local.aws_account
  peer_region   = "us-east-2"
  auto_accept   = false

  tags = local.common_tags

  provider = aws.us-west-2
}

resource "aws_vpc_peering_connection_accepter" "us_east_2-us_west-2" {
  provider                  = aws.us-east-2
  vpc_peering_connection_id = aws_vpc_peering_connection.us_west-2-us_east_2.id
  auto_accept               = true

  tags = local.common_tags
}

resource "aws_route" "us_west-2-us_east_2" {
  count = length(module.vpc_us_west_2.private_route_table_ids)
  route_table_id = module.vpc_us_west_2.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc_us_east_2.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_west-2-us_east_2.id

  provider = aws.us-west-2
}

resource "aws_route" "us_east_2-us_west-2" {
  count = length(module.vpc_us_east_2.private_route_table_ids)
  route_table_id = module.vpc_us_east_2.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc_us_west_2.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.us_east_2-us_west-2.id

  provider = aws.us-east-2
}
