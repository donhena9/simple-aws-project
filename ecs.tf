resource "aws_ecs_cluster" "httpbin_cluster" {
  name = "httpbin-cluster"
  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.httpbin_log_group.name
      }
    }
  }
}

resource "aws_ecs_task_definition" "httpbin" {
  family                   = "httpbin"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.httpbin_execution_role.arn

  container_definitions = jsonencode([
    {
      name     = "httpbin"
      image    = "kennethreitz/httpbin:latest"
    
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.httpbin_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "httbin-log-stream"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "httpbin_service" {
  name            = "httpbin-service"
  cluster         = aws_ecs_cluster.httpbin_cluster.id
  task_definition = aws_ecs_task_definition.httpbin.arn
  launch_type     = "FARGATE"
  desired_count   = var.service_count

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_httpbin.arn
    container_name   = "httpbin"
    container_port   = 80
  }

  network_configuration {
    assign_public_ip = true
    security_groups    = [aws_security_group.security_group.id]
    subnets = [
      aws_subnet.subnet-a.id,
      aws_subnet.subnet-b.id,
    ]
  }
}