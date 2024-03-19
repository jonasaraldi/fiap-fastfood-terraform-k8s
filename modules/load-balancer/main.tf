resource "aws_security_group" "lb-sg" {
  vpc_id = var.vpc_id

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name      = "${var.prefix}-lb-sg"
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb-sg-ingress-rule" {
  security_group_id = aws_security_group.lb-sg.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 0
  ip_protocol       = "TCP"
  to_port           = 0
}

resource "aws_lb" "load-balancer" {
  name                       = "${var.prefix}-lb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb-sg.id]
  subnets                    = [for subnet in var.subnet_ids : subnet]
  enable_deletion_protection = false

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}
