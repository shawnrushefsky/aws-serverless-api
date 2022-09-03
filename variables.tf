variable "api_spec" {
  type        = map(map(string))
  description = "A map like { endpoint: { method: lambda_name }}"
}

variable "api_name" {
  type        = string
  description = "A friendly api name"
}

variable "api_version" {
  type        = string
  description = "A semantic version number for the api"
  default     = "1.0"
}

variable "cognito_pool_name" {
  type = string
  default = ""
}