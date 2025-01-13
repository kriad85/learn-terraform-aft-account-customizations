# Provider configuration for the AFT management account (to read SSM parameter)
provider "aws" {
  alias  = "controller"
  region = "eu-west-3" # Replace with the AFT account's region

  assume_role {
    role_arn    = "arn:aws:iam::043309348131:role/AWSAFTExecution"
  }
}

# Fetch the Transit Gateway ID from the AFT Management Account's SSM Parameter Store
data "aws_ssm_parameter" "tgw_id" {
  provider = aws.controller
  name     = "/network/transit-gateway/id"
}

# Create a VPC in the Edge-Hub Account
resource "aws_vpc" "edge_hub_vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name        = "EdgeHub-VPC"
    Environment = "Production"
  }
}

# Create Subnets for the VPC
resource "aws_subnet" "edge_hub_subnets" {
  count = 2
  vpc_id            = aws_vpc.edge_hub_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.edge_hub_vpc.cidr_block, 4, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "EdgeHub-Subnet-${count.index}"
  }
}

# Create the Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "edge_hub_attachment" {
  transit_gateway_id = data.aws_ssm_parameter.tgw_id.value
  vpc_id             = aws_vpc.edge_hub_vpc.id
  subnet_ids         = aws_subnet.edge_hub_subnets[*].id

  tags = {
    Name        = "EdgeHub-TGW-Attachment"
    Environment = "Production"
  }
}