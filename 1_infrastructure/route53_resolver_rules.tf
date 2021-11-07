# us-east-1

resource "aws_security_group" "route53_endpoint_us_east_1" {
  name        = "${local.prefix}-route53-endpoint"
  description = "Allow all DNS traffic"
  vpc_id      = module.vpc_us_east_1.vpc_id

  ingress = [
    {
      description      = "DNS Traffic"
      from_port        = 53
      to_port          = 53
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description      = "DNS Traffic"
      from_port        = 53
      to_port          = 53
      protocol         = "udp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description      = "ALL Traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = local.common_tags
}

resource "aws_route53_resolver_endpoint" "inbound_us_east_1" {
  name      = "${local.prefix}-inbound-resolver-endpoint"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.route53_endpoint_us_east_1.id,
  ]

  ip_address {
    subnet_id = module.vpc_us_east_1.private_subnets[0]
  }

  ip_address {
    subnet_id = module.vpc_us_east_1.private_subnets[1]
  }

  tags = local.common_tags
}

# us-east-2

resource "aws_security_group" "route53_endpoint_us_east_2" {
  name        = "${local.prefix}-route53-endpoint"
  description = "Allow all DNS traffic"
  vpc_id      = module.vpc_us_east_2.vpc_id

  ingress = [
    {
      description      = "DNS Traffic"
      from_port        = 53
      to_port          = 53
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description      = "DNS Traffic"
      from_port        = 53
      to_port          = 53
      protocol         = "udp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description      = "ALL Traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = local.common_tags
  provider = aws.us-east-2
}

resource "aws_route53_resolver_endpoint" "inbound_us_east_2" {
  name      = "${local.prefix}-inbound-resolver-endpoint"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.route53_endpoint_us_east_2.id,
  ]

  ip_address {
    subnet_id = module.vpc_us_east_2.private_subnets[0]
  }

  ip_address {
    subnet_id = module.vpc_us_east_2.private_subnets[1]
  }

  tags = local.common_tags

  provider = aws.us-east-2
}

# us-west-2

resource "aws_security_group" "route53_endpoint_us_west_2" {
  name        = "${local.prefix}-route53-endpoint"
  description = "Allow all DNS traffic"
  vpc_id      = module.vpc_us_west_2.vpc_id

  ingress = [
    {
      description      = "DNS Traffic"
      from_port        = 53
      to_port          = 53
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description      = "DNS Traffic"
      from_port        = 53
      to_port          = 53
      protocol         = "udp"
      cidr_blocks      = ["10.0.0.0/8"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description      = "ALL Traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = local.common_tags
  provider = aws.us-west-2
}

resource "aws_route53_resolver_endpoint" "outbound_us_west_2" {
  name      = "${local.prefix}-outbound-resolver-endpoint"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.route53_endpoint_us_west_2.id,
  ]

  ip_address {
    subnet_id = module.vpc_us_west_2.private_subnets[0]
  }

  ip_address {
    subnet_id = module.vpc_us_west_2.private_subnets[1]
  }

  tags = local.common_tags

  provider = aws.us-west-2
}

# us-east-1

resource "aws_route53_resolver_rule" "us-east-1-rslvr" {
  domain_name          = "us-east-1.amazonaws.com"
  name                 = "${local.prefix}-us-east-1-amazonaws-com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_us_west_2.id

  dynamic "target_ip" {
    for_each = aws_route53_resolver_endpoint.inbound_us_east_1.ip_address
    content {
      ip = target_ip.value["ip"]
    }
  }

  tags = local.common_tags

  provider = aws.us-west-2
}

resource "aws_route53_resolver_rule" "us-east-1-vpce-rslvr" {
  domain_name          = "us-east-1.vpce.amazonaws.com"
  name                 = "${local.prefix}-us-east-1-vpce-amazonaws-com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_us_west_2.id

  dynamic "target_ip" {
    for_each = aws_route53_resolver_endpoint.inbound_us_east_1.ip_address
    content {
      ip = target_ip.value["ip"]
    }
  }

  tags = local.common_tags

  provider = aws.us-west-2
}

# us-east-2

resource "aws_route53_resolver_rule" "us-east-2-rslvr" {
  domain_name          = "us-east-2.amazonaws.com"
  name                 = "${local.prefix}-us-east-2-amazonaws-com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_us_west_2.id

  dynamic "target_ip" {
    for_each = aws_route53_resolver_endpoint.inbound_us_east_2.ip_address
    content {
      ip = target_ip.value["ip"]
    }
  }

  tags = local.common_tags

  provider = aws.us-west-2
}

resource "aws_route53_resolver_rule" "us-east-2-vpce-rslvr" {
  domain_name          = "us-east-2.vpce.amazonaws.com"
  name                 = "${local.prefix}-us-east-2-vpce-amazonaws-com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_us_west_2.id

  dynamic "target_ip" {
    for_each = aws_route53_resolver_endpoint.inbound_us_east_2.ip_address
    content {
      ip = target_ip.value["ip"]
    }
  }

  tags = local.common_tags

  provider = aws.us-west-2
}
