resource "aws_db_subnet_group" "this" {
  name       = "${var.app}-${var.env}"
  subnet_ids = var.subnets

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_security_group" "this" {
  name   = "${var.app}-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_db_parameter_group" "this" {
  name   = "rms-prod-paramgroup"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.app}-${var.env}"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  db_name                = var.app
  engine                 = "postgres"
  engine_version         = "16.1"
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}
