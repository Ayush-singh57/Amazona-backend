# 1. ECR & ECS Cluster
resource "aws_ecr_repository" "backend_repo" {
  name         = "${var.project_name}-repo"
  force_delete = true
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "${var.project_name}-cluster"
}

# 2. CloudWatch Logs 
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}-backend"
  retention_in_days = 7
}

# 3. IAM Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 4. Security Groups
resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id

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
  name   = "${var.project_name}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for testing
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Load Balancer & Target Group
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "${var.project_name}-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/products"
    interval            = 60
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 10
    matcher             = "200-499" #for health check
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# 6. ECS Task & Service
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "backend-container"
    image     = "${aws_ecr_repository.backend_repo.repository_url}:latest"
    essential = true
    portMappings = [{ containerPort = 4000, hostPort = 4000, protocol = "tcp" }]
    
    environment = [
      { "name": "MONGO_URI", "value": "mongodb+srv://ayush221018it_db_user:6fc4sZ9IZU707VN2@cluster0.w4v1jkr.mongodb.net/?appName=Cluster0" },
      { "name": "MONGODB_URI", "value": "mongodb+srv://ayush221018it_db_user:6fc4sZ9IZU707VN2@cluster0.w4v1jkr.mongodb.net/?appName=Cluster0" },
      { "name": "PORT", "value": "4000" }
    ]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "backend_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "backend-container"
    container_port   = 4000
  }
}