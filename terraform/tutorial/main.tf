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

# module "rds" {
#   source     = "terraform-aws-modules/rds/aws"
#   version    = "4.2.0"
#   identifier = "sunapi"

#   engine         = "postgres"
#   engine_version = "14.2"
#   instance_class = "db.t3.micro"

#   db_name  = "sunapi"
#   username = "ateam_master"
#   password = "Yk^w?S9KL$byDB6J"
#   port     = "5432"

#   create_db_option_group    = false
#   create_db_parameter_group = false

#   allocated_storage = 5

#   vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.https.id, aws_security_group.egress_all.id, aws_security_group.ingress_api.id]

#   #   maintenance_window = "Mon:00:00-Mon:03:00"
#   #   backup_window      = "03:00-06:00"

#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically
#   #   monitoring_interval = "30"
#   #   monitoring_role_name = "MyRDSMonitoringRole"
#   #   create_monitoring_role = true

#   tags = {
#     Owner       = var.app_name
#     Environment = "dev"
#   }

#   create_db_subnet_group = true
#   subnet_ids             = [aws_subnet.private_d.id, aws_subnet.private_e.id, aws_subnet.public_d.id, aws_subnet.public_e.id, ]

#   # DB parameter group
#   #   family = "mysql5.7"

#   # DB option group
#   #   major_engine_version = "5.7"

#   # Database Deletion Protection
#   deletion_protection = false
# }

# resource "aws_eip" "lb" {
#   instance = aws_instance.test.id
#   vpc      = true
# }

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "ssh traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.role.name
# }

# data "aws_iam_policy" "ssm_ec2" {
#   arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_role_policy" "ssm_ec2" {
#   name   = "ssm_ec2"
#   role   = aws_iam_role.ec2_ar
#   policy = data.aws_iam_policy.ssm_ec2.json
# }

# resource "aws_iam_role" "ec2_ar" {
#   name = "test_role"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }

# resource "aws_instance" "test" {
#   subnet_id              = aws_subnet.public_d.id
#   vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.https.id, aws_security_group.egress_all.id, aws_security_group.ssh.id]
#   tags = {
#     Name = "test"
#   }
#   instance_type = "t3.micro"
#   ami           = "ami-0f9fc25dd2506cf6d"
# }
