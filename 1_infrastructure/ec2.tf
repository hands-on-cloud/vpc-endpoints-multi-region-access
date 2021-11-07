locals {
  ec2_instance_type = "t3.micro"
  ssh_key_name = "Lenovo-T410"
}

# Latest Amazon Linux 2

data "aws_ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  provider = aws.us-west-2
}

resource "aws_security_group" "ssh" {
  name        = "${local.prefix}-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc_us_west_2.vpc_id

  ingress = [
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
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

  tags = {
    Name = "allow_ssh"
  }

  provider = aws.us-west-2
}

# EC2 demo Instance Profile

resource "aws_iam_instance_profile" "ec2_demo" {
  name = "${local.prefix}-ec2-demo-instance-profile"
  role = aws_iam_role.ec2_demo.name
}

resource "aws_iam_role" "ec2_demo" {
  name = "${local.prefix}-ec2-demo-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# Allow Systems Manager to manage EC2 instance

resource "aws_iam_policy_attachment" "ec2_ssm" {
  name       = "${local.prefix}-ec2-demo-role-attachment"
  roles      = [aws_iam_role.ec2_demo.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ec2_s3_read_only" {
  name       = "${local.prefix}-ec2-demo-role-attachment"
  roles      = [aws_iam_role.ec2_demo.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# EC2 demo instance

resource "aws_network_interface" "ec2_demo" {
  subnet_id   = module.vpc_us_west_2.private_subnets[0]
  private_ips = ["10.2.0.101"]
  security_groups = [aws_security_group.ssh.id]

  provider = aws.us-west-2
}

resource "aws_instance" "ec2_demo" {
  ami                  = data.aws_ami.amazon-linux-2.id
  instance_type        = local.ec2_instance_type
  availability_zone    = "us-west-2a"
  iam_instance_profile = aws_iam_instance_profile.ec2_demo.name

  network_interface {
    network_interface_id = aws_network_interface.ec2_demo.id
    device_index         = 0
  }

  key_name = local.ssh_key_name

  tags = {
    Name = "${local.prefix}-ec2-demo"
  }

  provider = aws.us-west-2

  depends_on = [
    module.endpoints_us_west_2
  ]
}

# EC2 public instance

resource "aws_instance" "public" {
  ami                  = data.aws_ami.amazon-linux-2.id
  instance_type        = local.ec2_instance_type
  availability_zone    = "us-west-2a"
  subnet_id = module.vpc_us_west_2.public_subnets[0]
  iam_instance_profile = aws_iam_instance_profile.ec2_demo.name

  vpc_security_group_ids = [aws_security_group.ssh.id]

  key_name = local.ssh_key_name

  tags = {
    Name = "${local.prefix}-ec2-public"
  }

  provider = aws.us-west-2
}
