resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet-a" {
  cidr_block              = var.default_network_cidr_a
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet-b" {
  cidr_block              = var.default_network_cidr_b
  availability_zone       = "us-east-1b"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_a_route" {
  subnet_id      = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "subnet_b_route" {
  subnet_id      = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_lb" "lb_httpbin" {
  name               = "balancer-httpbin"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group.id]
  subnets = [
    aws_subnet.subnet-a.id,
    aws_subnet.subnet-b.id,
  ]

  # TODO: balancer logs to CloudWatch or s3
}

resource "aws_lb_target_group" "tg_httpbin" {
  name        = "lb-target-group-httpbin"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb_httpbin.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb_httpbin.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.httpbin_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_httpbin.arn
  }
}

resource "aws_lb_listener_rule" "redirect_to_www" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type = "redirect"

    redirect {
      host        = "www.${var.domain_name}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["${var.domain_name}"]
    }
  }
}
