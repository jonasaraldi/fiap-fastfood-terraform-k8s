resource "aws_apigatewayv2_api" "api-gateway" {
  name          = "fastfood-api"
  protocol_type = "HTTP"
  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_apigatewayv2_stage" "agw-stage" {
  api_id = aws_apigatewayv2_api.api-gateway.id
  name   = "stage"
}

resource "aws_apigatewayv2_vpc_link" "vpc-link" {
  name               = "${var.prefix}-vl"
  security_group_ids = [var.lb_sg_id]
  subnet_ids         = var.subnet_ids

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_apigatewayv2_integration" "agw-integration" {
  api_id             = aws_apigatewayv2_api.api-gateway.id
  integration_uri    = var.lb_listener_arn
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc-link.id

  #   tls_config {
  #     server_name_to_verify = "example.com"
  #   }

  #   request_parameters = {
  #     "append:header.authforintegration" = "$context.authorizer.authorizerResponse"
  #     "overwrite:path"                   = "staticValueForIntegration"
  #   }

  #   response_parameters {
  #     status_code = 403
  #     mappings = {
  #       "append:header.auth" = "$context.authorizer.authorizerResponse"
  #     }
  #   }

  #   response_parameters {
  #     status_code = 200
  #     mappings = {
  #       "overwrite:statuscode" = "204"
  #     }
  #   }
}

resource "aws_apigatewayv2_route" "agw-route" {
  api_id    = aws_apigatewayv2_api.api-gateway.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.agw-integration.id}"
}
