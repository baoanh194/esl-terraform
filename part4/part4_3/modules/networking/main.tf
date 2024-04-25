# This data block retrieves information about the availability zones 
# available in the current AWS region. It doesn't 
# create any resources but stores the information for later use.
data "aws_availability_zones" "available" {}

# Creates a Virtual Private Cloud (VPC) with public 
# and private subnets across multiple availability zones. 
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"
  
  name    = "${var.project_name}-vpc"
  # The IP range for the VPC
  cidr    = "10.0.0.0/16"
  # Availability zones obtained from the data block
  azs     = data.aws_availability_zones.available.names

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] 
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  create_database_subnet_group = true
  # Configures NAT gateways for private subnets.
  enable_nat_gateway           = true
  single_nat_gateway           = true
}

# Load Balancer Security Group
# creates a security group for a load balancer. It allows incoming 
# traffic on port 80 from any source.
module "lb_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Web Server Security Group
# It allows incoming traffic on port 8080 only from the security group 
# of the load balancer and allows SSH traffic from the specified CIDR block.
module "web_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port        = 8080
      security_groups = [module.lb_sg.security_group.id]
    },

    {
      port        = 22
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

# Database Security Group
# This module creates a security group for a database. 
# It allows incoming traffic on port 3306 only from the security group of the web servers.
module "db_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port            = 3306
      security_groups = [module.web_sg.security_group.id]
    }
  ]
}
