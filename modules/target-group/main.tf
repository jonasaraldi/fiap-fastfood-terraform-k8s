resource "aws_lb_target_group" "lb-target-group" {
  name            = "${var.prefix}-lb-tg"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = var.vpc_id
  target_type     = "ip"
  ip_address_type = "ipv4"
  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_lb_target_group_attachment" "lb-target-group-attachment" {
  target_group_arn = aws_lb_target_group.lb-target-group.arn
  target_id        = var.target_ip_address
  port             = 80
}
