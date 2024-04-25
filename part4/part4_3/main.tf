locals {
  project_name = "rabbitmq-terraform"
}

provider "aws" {
  region = "us-west-2"
}

module "networking" {
  source = "./modules/networking"
  project_name = local.project_name
}

module "database" {
  source = "./modules/database"
  project_name = local.project_name
  # vpc = module.networking.vpc
  # sg = module.networking.sg
}

module "autoscaling" {
  source = "./modules/autoscaling"
  project_name = local.project_name
  # vpc = module.networking.vpc
  # sg = module.networking.sg
  # db_config = module.database.config
  # ssh_keypair = var.ssh_keypair
}
