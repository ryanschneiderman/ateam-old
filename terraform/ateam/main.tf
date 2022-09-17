terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  required_version = "~> 1.1.7"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_ecr_repository" "ateam_app" {
  name                 = "${var.app_name}_app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.ateam_app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

module "rds" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "4.2.0"
  identifier = var.app_name

  engine         = "postgres"
  engine_version = "14.2"
  instance_class = "db.t3.micro"

  db_name  = var.app_name
  username = "postgres"
  password = "Yk^w?S9KL!byDB6J"
  port     = "5432"

  create_db_option_group    = false
  create_db_parameter_group = false

  allocated_storage = 5

  vpc_security_group_ids = [aws_security_group.allow_tls.id, "sg-01f17a215982bcf91"]

  #   maintenance_window = "Mon:00:00-Mon:03:00"
  #   backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  #   monitoring_interval = "30"
  #   monitoring_role_name = "MyRDSMonitoringRole"
  #   create_monitoring_role = true

  tags = {
    Owner       = var.app_name
    Environment = "dev"
  }

  create_db_subnet_group = true
  subnet_ids             = module.vpc.public_subnets

  # DB parameter group
  #   family = "mysql5.7"

  # DB option group
  #   major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false
}

resource "aws_kms_key" "ateam" {
  description             = var.app_name
  deletion_window_in_days = 7
}

output "rds_address" {
  value = module.rds.db_instance_address
}
