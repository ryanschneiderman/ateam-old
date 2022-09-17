resource "aws_lb" "ateam" {
  name               = var.app_name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ateam_lb_sg.id]
  subnets            = module.vpc.public_subnets
  internal           = false

  # enable_deletion_protection = true

  tags = {
    Environment = "Development"
  }
  access_logs {
    bucket  = "ateam-lb-logs"
    enabled = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ateam.arn
  port              = "80"
  protocol          = "HTTP"

  #   default_action {
  #     type = "redirect"

  #     redirect {
  #       port        = 443
  #       protocol    = "HTTPS"
  #       status_code = "HTTP_301"
  #     }
  #   }
  default_action {
    target_group_arn = aws_lb_target_group.ateam2.id
    type             = "forward"
  }
}

# resource "aws_alb_listener" "https" {
#   load_balancer_arn = aws_lb.ateam.arn
#   port              = 443
#   protocol          = "HTTPS"

#   ssl_policy      = "ELBSecurityPolicy-2016-08"
#   certificate_arn = var.alb_tls_cert_arn

#   default_action {
#     target_group_arn = aws_alb_target_group.ateam.id
#     type             = "forward"
#   }
# }

resource "aws_lb_target_group" "ateam" {
  name        = var.app_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  depends_on = [
    aws_lb.ateam
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "ateam2" {
  name        = "ateam2"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  depends_on = [
    aws_lb.ateam
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ateam_lb_sg" {
  name        = "${var.app_name}_lb_sg"
  description = "ateam load balancer sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol         = "TCP"
    from_port        = 8080
    to_port          = 8080
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol         = "TCP"
    from_port        = 80
    to_port          = 8080
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "TCP"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "TCP"
    from_port        = 443
    to_port          = 443
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

  tags = {
    Name = "${var.app_name}_lb_sg"
  }
}
