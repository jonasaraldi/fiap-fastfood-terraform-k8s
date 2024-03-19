output "base_url" {
  value = aws_apigatewayv2_stage.agw-stage.invoke_url
}