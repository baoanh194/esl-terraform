terraform {
  backend "s3" {
    bucket         = "rabbitmq-s3-backend"
    key            = "rabbit/bao"
    region         = "us-west-2"
    encrypt        = true
	role_arn       = "arn:aws:iam::958741235898:role/RabbitmqS3BackendRole"
    dynamodb_table = "rabbitmq-s3-backend"
  }
#   required_version = ">= 0.15"
#   required_providers {
#     null = {
#       source  = "hashicorp/null"
#       version = "~> 3.0"
#     }
#   }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.ami.id
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Server"
  }
}

output "public_ip" {
  value = aws_instance.server.public_ip
}