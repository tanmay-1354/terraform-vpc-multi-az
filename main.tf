module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  project_name         = var.project_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "secrets_manager" {
  source = "./modules/secrets_manager"

  environment         = var.environment
  database_name       = var.database_name
  master_username     = var.database_master_username
  secret_description  = "RDS database credentials for ${var.environment}"
}

module "rds" {
  source = "./modules/rds"

  environment              = var.environment
  database_name            = var.database_name
  engine                   = var.database_engine
  instance_class           = var.database_instance_class
  allocated_storage        = var.database_allocated_storage
  master_username          = var.database_master_username
  master_password          = module.secrets_manager.db_password
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnet_ids
  allowed_security_group_ids = []

  depends_on = [module.vpc, module.secrets_manager]
}
