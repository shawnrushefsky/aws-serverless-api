terraform {
  required_version = ">= 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  all_methods = {
    for i, v in flatten([
      for path, config in var.api_spec : [
        for method, arn in config : {
          path   = path,
          method = upper(method)
          arn    = arn
        }
      ]
    ]) : i => v
  }
}

resource "aws_api_gateway_rest_api" "gateway" {
  name           = var.api_name
  api_key_source = "HEADER"
}

resource "aws_api_gateway_resource" "paths" {
  for_each = var.api_spec

  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = each.key
  rest_api_id = aws_api_gateway_rest_api.gateway.id
}

resource "aws_api_gateway_method" "methods" {
  for_each = local.all_methods

  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.paths[each.value.path].id
  http_method   = each.value.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "endpoints" {
  for_each = local.all_methods

  http_method             = aws_api_gateway_method.methods[each.key].http_method
  resource_id             = aws_api_gateway_resource.paths[each.value.path].id
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = each.value.arn
}

resource "aws_lambda_permission" "invoke_from_gateway" {
  for_each = local.all_methods

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.gateway.id}/*/${each.value.method}${each.value.path}"
}