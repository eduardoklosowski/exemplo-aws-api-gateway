output "lambda_addtarefa_invokearn" {
  value = aws_lambda_function.addtarefa.invoke_arn
}

output "lambda_listtarefa_invokearn" {
  value = aws_lambda_function.listtarefa.invoke_arn
}

output "lambda_gettarefa_invokearn" {
  value = aws_lambda_function.gettarefa.invoke_arn
}

output "lambda_edittarefa_invokearn" {
  value = aws_lambda_function.edittarefa.invoke_arn
}

output "lambda_deletetarefa_invokearn" {
  value = aws_lambda_function.deletetarefa.invoke_arn
}
