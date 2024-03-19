resource "aws_cognito_user_pool" "this" {
  name = "${var.app}-${var.env}"

  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
  }

  alias_attributes = ["email", "phone_number"]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  deletion_protection = "INACTIVE"
  mfa_configuration   = "OFF"

  tags = {
    org       = var.org
    app       = var.app
    env       = var.env
    terraform = true
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name = "${var.app}-${var.env}-client"

  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret     = false
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_CUSTOM_AUTH"]
}

resource "aws_cognito_user" "this" {
  user_pool_id = aws_cognito_user_pool.this.id
  username     = "00000000000"

  attributes = {
    name  = "anonymous"
    email = "anonymous@anonymous.com"
  }
}
