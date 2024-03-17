output "sg_id" {
  value = aws_security_group.lb-sg.id
}

output "listener_arn" {
  value = aws_lb_listener.lb-listener.arn
}