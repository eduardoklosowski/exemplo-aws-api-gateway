output "main_url" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.api.id}/${aws_api_gateway_deployment.main.stage_name}/_user_request_"
}
