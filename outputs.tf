# output "lambda_aliases" {
#   value = { for i, value in local.all_methods : value.function_name => aws_lambda_alias.lambda_aliases[i].arn }
# }

output "invoke_url" {
  value = aws_api_gateway_stage.prod.invoke_url
}

output "api_id" {
  value = aws_api_gateway_rest_api.gateway.id
}

output "resources" {
  value = { for i, value in aws_api_gateway_resource.paths : value.path_part => value.id }
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.gateway.execution_arn
}