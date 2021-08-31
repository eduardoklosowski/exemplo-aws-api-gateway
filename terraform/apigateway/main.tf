resource "aws_api_gateway_rest_api" "api" {
  name = "exemploapi"
}

resource "aws_api_gateway_resource" "tarefas" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "tarefas"
}

resource "aws_api_gateway_resource" "tarefas_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.tarefas.id
  path_part   = "{id+}"
}

resource "aws_api_gateway_method" "addtarefa" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.tarefas.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "addtarefa" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.tarefas.id
  http_method             = aws_api_gateway_method.addtarefa.http_method
  type                    = "AWS_PROXY"
  uri                     = var.lambda_addtarefa_invokearn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method" "listtarefa" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.tarefas.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "listtarefa" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.tarefas.id
  http_method             = aws_api_gateway_method.listtarefa.http_method
  type                    = "AWS_PROXY"
  uri                     = var.lambda_listtarefa_invokearn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method" "gettarefa" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.tarefas_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gettarefa" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.tarefas_id.id
  http_method             = aws_api_gateway_method.gettarefa.http_method
  type                    = "AWS_PROXY"
  uri                     = var.lambda_gettarefa_invokearn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method" "edittarefa" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.tarefas_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "edittarefa" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.tarefas_id.id
  http_method             = aws_api_gateway_method.edittarefa.http_method
  type                    = "AWS_PROXY"
  uri                     = var.lambda_edittarefa_invokearn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method" "deletetarefa" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.tarefas_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "deletetarefa" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.tarefas_id.id
  http_method             = aws_api_gateway_method.deletetarefa.http_method
  type                    = "AWS_PROXY"
  uri                     = var.lambda_deletetarefa_invokearn
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "main"
  depends_on = [
    aws_api_gateway_method.addtarefa,
    aws_api_gateway_integration.addtarefa,
    aws_api_gateway_method.listtarefa,
    aws_api_gateway_integration.listtarefa,
    aws_api_gateway_method.gettarefa,
    aws_api_gateway_integration.gettarefa,
    aws_api_gateway_method.edittarefa,
    aws_api_gateway_integration.edittarefa,
    aws_api_gateway_method.deletetarefa,
    aws_api_gateway_integration.deletetarefa
  ]
}
