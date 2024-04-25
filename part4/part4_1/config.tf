terraform {
  required_version = ">= 1.2"
}

provider "aws" {
  profile = "default"
  region = "eu-west-2"
}
