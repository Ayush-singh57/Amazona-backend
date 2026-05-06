# 1. SECURITY GROUPS
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id      = var.vpc_id
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  vpc_id      = var.vpc_id
  description = "Allow inbound from ALB only"

  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. APPLICATION LOAD BALANCER
resource "aws_lb" "backend_alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.project_name}-ecs-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# 3. IAM ROLE (Allows ECS to pull Docker images and log to CloudWatch)
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 4. ECR REPOSITORY & ECS CLUSTER
resource "aws_ecr_repository" "backend_repo" {
  name                 = "${var.project_name}-backend-repo"
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"
}

# 5. FARGATE TASK & SERVICE
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "${var.project_name}-backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "backend-container"
    image     = "nginx:latest" # PLACEHOLDER until you push your Node.js image via CI/CD
    essential = true
    portMappings = [{
      containerPort = 4000
      hostPort      = 4000
    }]
    environment = [
      { name = "MONGODB_URI", value = var.mongodb_uri },
      { name = "JWT_SECRET", value = "production_secret_key" }
    ]
  }])
}

resource "aws_ecs_service" "backend_service" {
  name            = "${var.project_name}-backend-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # Set to true to allow pulling images from ECR without a NAT Gateway
  }

load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "backend-container"
    container_port   = 4000 
  }
}