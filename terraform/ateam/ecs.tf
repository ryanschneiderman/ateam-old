resource "aws_ecs_cluster" "ateam" {
  name = var.app_name

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ateam.arn
      logging    = "DEFAULT"
    }
  }
}

data "aws_security_group" "default" {
  id = "sg-01f17a215982bcf91"
}

resource "aws_ecs_service" "ateam" {
  name                               = var.app_name
  cluster                            = aws_ecs_cluster.ateam.id
  task_definition                    = aws_ecs_task_definition.ateam.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.ateam2.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }
  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ateam_lb_sg.id]
    assign_public_ip = true
  }
}

# # We'll eventually want a place to put our logs.
# resource "aws_cloudwatch_log_group" "ateam" {
#   name = "/ecs/ateam"
# }

resource "aws_security_group" "ecs_tasks" {
  name   = "${var.app_name}-ecs-tasks"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port
    to_port          = var.container_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_ecs_task_definition" "ateam" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name        = var.app_name
      image       = "498061775412.dkr.ecr.us-east-1.amazonaws.com/ateam_app:${var.app_version}"
      cpu         = 256
      memory      = 512
      essential   = true
      command     = ["sh", "entrypoint.sh"],
      environment = var.environmentvar
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "us-east-1"
          awslogs-group         = "/ecs/ateam"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
}


resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
