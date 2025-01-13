# Provider configuration for the AFT management account using assume_role
provider "aws" {
  alias  = "controller"
  region = "eu-west-3" # Replace with your desired region

  assume_role {
    role_arn    = "arn:aws:iam::043309348131:role/AWSAFTExecution"
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

# Resource Access Manager (RAM) Resource Share
resource "aws_ram_resource_share" "tgw_share" {
  name = "TGW-Share"
  allow_external_principals = false # Set to true if sharing with external organizations

  tags = {
    Name        = "TransitGatewayResourceShare"
    Environment = "Production"
  }
}

# Add the Transit Gateway to the Resource Share
resource "aws_ram_resource_association" "tgw_association" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
  resource_arn       = aws_ec2_transit_gateway.example.arn
}

# Add the Target Account as a Principal
resource "aws_ram_principal_association" "tgw_principal" {
  resource_share_arn = aws_ram_resource_share.tgw_share.arn
  principal          = "050752649770" # Replace with the AWS Account ID of the target account
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
