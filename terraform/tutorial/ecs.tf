# ecs.tf
resource "aws_ecs_cluster" "app" {
  name = "app"
}

resource "aws_ecs_service" "ateam_test" {
  name            = "ateam_test"
  task_definition = aws_ecs_task_definition.sun_api.arn
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.app.id
  desired_count   = 1
  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_api.id,
    ]

    subnets = [
      aws_subnet.private_d.id,
      aws_subnet.private_e.id,
    ]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.sun_api.arn
    container_name   = "sun-api"
    container_port   = "8080"
  }
}

# We'll eventually want a place to put our logs.
resource "aws_cloudwatch_log_group" "sun_api" {
  name = "/ecs/sun-api"
}

# Here's our task definition, which defines the task that will be running to provide
# our service. The idea here is that if the service decides it needs more capacity,
# this task definition provides a perfect blueprint for building an identical container.
#
# If you're using your own image, use the path to your image instead of mine,
# i.e. `<your_dockerhub_username>/sun-api:latest`.
resource "aws_ecs_task_definition" "sun_api" {
  family             = "sun-api"
  execution_role_arn = aws_iam_role.sun_api_task_execution_role.arn

  container_definitions = <<EOF
  [
    {
      "name": "sun-api",
      "image": "ghcr.io/jimmysawczuk/sun-api:latest",
      "portMappings": [
        {
          "containerPort": 8080
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "us-east-1",
          "awslogs-group": "/ecs/sun-api",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  EOF

  # These are the minimum values for Fargate containers.
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  # This is required for Fargate containers (more on this later).
  network_mode = "awsvpc"
}

# resource "aws_ecs_task_definition" "sun_api" {
#   family                   = "sun-api"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 256
#   memory                   = 512
#   network_mode             = "awsvpc"
#   execution_role_arn       = aws_iam_role.sun_api_task_execution_role.arn
#   container_definitions = jsonencode([
#     {
#       name        = "sun-api"
#       image       = "498061775412.dkr.ecr.us-east-1.amazonaws.com/ateam_app:0.0.6"
#       cpu         = 256
#       memory      = 512
#       essential   = true
#       command     = ["sh", "entrypoint.sh"],
#       environment = var.environmentvar
#       portMappings = [
#         {
#           containerPort = 8080
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-region        = "us-east-1"
#           awslogs-group         = "/ecs/sun-api"
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#     },
#   ])
# }


# This is the role under which ECS will execute our task. This role becomes more important
# as we add integrations with other AWS services later on.

# The assume_role_policy field works with the following aws_iam_policy_document to allow
# ECS tasks to assume this role we're creating.
resource "aws_iam_role" "sun_api_task_execution_role" {
  name               = "sun-api-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Normally we'd prefer not to hardcode an ARN in our Terraform, but since this is
# an AWS-managed policy, it's okay.
data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.sun_api_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}
