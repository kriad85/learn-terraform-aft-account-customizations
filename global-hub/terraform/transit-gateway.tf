# Provider configuration for the AFT management account using assume_role
provider "aws" {
  alias  = "controller"
  region = "eu-west-3" # Replace with your desired region

  assume_role {
    role_arn    = "{{ target_admin_role_arn }}"
  }
}

# Transit Gateway Resource in the Network Account
resource "aws_ec2_transit_gateway" "example" {
  description = "Transit Gateway for Networking"
  tags = {
    Name        = "Network-Transit-Gateway"
    Environment = "Production"
  }
}

# SSM Parameter in the AFT Management Account
resource "aws_ssm_parameter" "transit_gateway_id" {
  provider = aws.controller

  name        = "/network/transit-gateway/id"
  description = "Transit Gateway ID from the network account"
  type        = "String"
  value       = aws_ec2_transit_gateway.example.id
  tags = {
    Environment = "Dev"
  }
}
