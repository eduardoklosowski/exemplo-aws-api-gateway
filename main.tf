terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }
  backend "s3" {
    bucket                      = "config"
    key                         = "exemplo-aws-api-gateway.tfstate"
    access_key                  = "teste"
    secret_key                  = "teste"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    endpoint                    = "http://localhost:4566"
    sts_endpoint                = "http://localhost:4566"
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_force_path_style         = true

  endpoints {
    apigateway = "http://localhost:4566"
    cloudwatch = "http://localhost:4566"
    iam        = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    s3         = "http://localhost:4566"
  }
}

variable "pg_host" {
  description = "Endereço do servidor PostgreSQL"
  type        = string
}

variable "pg_port" {
  description = "Porta do servidor PostgreSQL"
  type        = number
}

variable "pg_user" {
  description = "Usuário do servidor PostgreSQL"
  type        = string
}

variable "pg_pass" {
  description = "Senha do servidor PostgresSQL"
  type        = string
}

variable "pg_dbname" {
  description = "Nome do banco de dados do servidor PostgreSQL"
  type        = string
}

module "iam" {
  source = "./terraform/iam"
}

module "lambda" {
  source = "./terraform/lambda"

  iam_role_arn = module.iam.iam_role_arn
  pg_host      = var.pg_host
  pg_port      = var.pg_port
  pg_user      = var.pg_user
  pg_pass      = var.pg_pass
  pg_dbname    = var.pg_dbname
}

module "apigateway" {
  source = "./terraform/apigateway"

  lambda_addtarefa_invokearn    = module.lambda.lambda_addtarefa_invokearn
  lambda_listtarefa_invokearn   = module.lambda.lambda_listtarefa_invokearn
  lambda_gettarefa_invokearn    = module.lambda.lambda_gettarefa_invokearn
  lambda_edittarefa_invokearn   = module.lambda.lambda_edittarefa_invokearn
  lambda_deletetarefa_invokearn = module.lambda.lambda_deletetarefa_invokearn
}

output "main_url" {
  description = "Endpoint do API Gateway"
  value       = module.apigateway.main_url
}
