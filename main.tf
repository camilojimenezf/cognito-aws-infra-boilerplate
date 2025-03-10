module "networking" {
  source        = "./networking"
  project_name = var.project_name
  environment  = var.environment
}

module "storage" {
  source        = "./storage"
  project_name = var.project_name
  environment  = var.environment
}

module "database" {
  source = "./database"
  project_name = var.project_name
  environment  = var.environment
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password

  vpc_id             = module.networking.vpc_id
  ecs_security_group = module.networking.ecs_security_group_id
  private_subnet_ids = module.networking.private_subnet_ids

  depends_on = [module.networking]
}

module "compute" {
  source        = "./compute"
  project_name = var.project_name
  environment  = var.environment
  cognito_user_pool_id = var.cognito_user_pool_id
  cognito_client_id = var.cognito_client_id

  private_subnet_ids   = module.networking.private_subnet_ids
  ecs_security_group   = module.networking.ecs_security_group_id
  alb_target_group_arn = module.networking.alb_target_group_arn
  db_host     = module.database.db_endpoint
  db_port     = "5432"
  db_name     = module.database.db_name
  db_username = module.database.db_username
  db_password = module.database.db_password

  depends_on = [module.networking, module.database]
}

module "dns" {
  source        = "./dns"
  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name

  alb_dns_name = module.networking.alb_dns_name
  alb_zone_id  = module.networking.alb_zone_id
  alb_arn      = module.networking.alb_arn
  alb_target_group_arn = module.networking.alb_target_group_arn

  depends_on = [module.networking, module.compute]
}

module "integrations" {
  source = "./integrations"
  environment = var.environment
  project_name = var.project_name
  domain_name  = var.domain_name

  s3_bucket_domain_name = module.storage.s3_bucket_domain_name
  s3_bucket_id = module.storage.s3_bucket_id
  certificate_arn = module.dns.certificate_arn
  route53_zone_id = module.dns.route53_zone_id
  s3_bucket_arn = module.storage.s3_bucket_arn

  depends_on = [module.dns, module.storage]
}
