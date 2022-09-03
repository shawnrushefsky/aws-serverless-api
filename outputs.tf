output "lambda_aliases" {
  value = { for i, value in local.all_methods: value.function_name => aws_lambda_alias.lambda_aliases[i].arn}
}

output "invoke_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}