data "archive_file" "code" {
  type        = "zip"
  source_file = "tarefa.py"
  output_path = "outputs/tarefa.zip"
}

resource "aws_lambda_function" "addtarefa" {
  function_name    = "exemploapi_addtarefa"
  role             = var.iam_role_arn
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  handler          = "tarefa.add_tarefa"
  source_code_hash = data.archive_file.code.output_base64sha256
  publish          = true
  environment {
    variables = {
      PG_DSN = "host=${var.pg_host} port=${var.pg_port} user=${var.pg_user} password=${var.pg_pass} dbname=${var.pg_dbname}"
    }
  }
}

resource "aws_lambda_function" "listtarefa" {
  function_name    = "exemploapi_listtarefa"
  role             = var.iam_role_arn
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  handler          = "tarefa.list_tarefa"
  source_code_hash = data.archive_file.code.output_base64sha256
  publish          = true
  environment {
    variables = {
      PG_DSN = "host=${var.pg_host} port=${var.pg_port} user=${var.pg_user} password=${var.pg_pass} dbname=${var.pg_dbname}"
    }
  }
}

resource "aws_lambda_function" "gettarefa" {
  function_name    = "exemploapi_gettarefa"
  role             = var.iam_role_arn
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  handler          = "tarefa.get_tarefa"
  source_code_hash = data.archive_file.code.output_base64sha256
  publish          = true
  environment {
    variables = {
      PG_DSN = "host=${var.pg_host} port=${var.pg_port} user=${var.pg_user} password=${var.pg_pass} dbname=${var.pg_dbname}"
    }
  }
}

resource "aws_lambda_function" "edittarefa" {
  function_name    = "exemploapi_edittarefa"
  role             = var.iam_role_arn
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  handler          = "tarefa.edit_tarefa"
  source_code_hash = data.archive_file.code.output_base64sha256
  publish          = true
  environment {
    variables = {
      PG_DSN = "host=${var.pg_host} port=${var.pg_port} user=${var.pg_user} password=${var.pg_pass} dbname=${var.pg_dbname}"
    }
  }
}

resource "aws_lambda_function" "deletetarefa" {
  function_name    = "exemploapi_deletetarefa"
  role             = var.iam_role_arn
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  handler          = "tarefa.delete_tarefa"
  source_code_hash = data.archive_file.code.output_base64sha256
  publish          = true
  environment {
    variables = {
      PG_DSN = "host=${var.pg_host} port=${var.pg_port} user=${var.pg_user} password=${var.pg_pass} dbname=${var.pg_dbname}"
    }
  }
}
