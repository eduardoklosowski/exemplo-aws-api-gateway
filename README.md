# Exemplo de AWS API Gateway com Lambda

Código de exemplo de uma [API Rest](https://www.restapitutorial.com/) utilizando [API Gateway](https://docs.aws.amazon.com/apigateway/) e [Lambda](https://docs.aws.amazon.com/lambda/) da [AWS](https://aws.amazon.com/pt/), com deploy através do [Terraform](https://www.terraform.io/) no [LocalStack](https://localstack.cloud/).

## Subir ambiente

Esse exemplo utiliza um banco de dados [PostgreSQL](https://hub.docker.com/_/postgres) e o [LocalStack](https://hub.docker.com/r/localstack/localstack) através do [docker-compose](https://docs.docker.com/compose/).

Sua configuração pode ser copiada com:

```sh
cp .env.example .env
```

E os serviços iniciados com:

```sh
docker-compose up
```

Para realizar algumas etapas do processo é necessário utilizar o [AWS CLI](https://docs.aws.amazon.com/cli/) que precisa ser instalado (usado neste exemplo o [LocalStack AWS CLI](https://github.com/localstack/awscli-local)). Para isso, primeiramente crie um virtualenv com Python 3, atualize esse ambiente e instale o CLI:

```sh
python3 -m venv env
. env/bin/activate
pip install -U pip setuptools wheel
pip install -r requirements-local.txt
```

## Deploy manual

Esse é um exemplo de deploy manual utilizando o AWS CLI diretamente.

### IAM

O primeiro recurso a ser criado é uma "role" para definir as permissões com as quais os lambdas irão executar:

```sh
awslocal iam create-role \
  --role-name exemploapi_lambda \
  --assume-role-policy-document '{"Version": "2012-10-17", "Statement": [{"Effect": "Allow", "Principal": {"Service": ["lambda.amazonaws.com", "apigateway.amazonaws.com"]}, "Action": "sts:AssumeRole"}]}'
```

### Lambdas

Para fazer o deploy dos lambdas, primeiramente é necessário cria um arquivo "Zip" contento o código fonte, que pode ser feito com:

```sh
zip arquivo.zip arquivo.py
```

Para criar o lambda, deve-se seguir o exemplo a baixo:

```sh
awslocal lambda create-function \
  --function-name exemploapi_funcao \
  --role arn:aws:iam::000000000000:role/exemploapi_lambda \
  --runtime python3.8 \
  --zip-file fileb://arquivo.zip \
  --handler arquivo.handler \
  --publish
  --environment Variables={KeyName1=string,KeyName2=string}
```

A atualização do código ou configuração podem ser feitas segundo os comandos a baixo respectivamente:

```sh
awslocal lambda update-function-code \
  --function-name exemploapi_funcao \
  --zip-file fileb://arquivo.zip

awslocal lambda update-function-configuration \
  --function-name exemploapi_funcao
  --environment Variables={KeyName1=string,KeyName2=string}
```

A execução do lambda pode ser feito através do comando:

```sh
awslocal lambda invoke \
  --function-name exemploapi_funcao \
  --payload '{"key": "value"}' \
  output.json
```

Para ver o log da execução é necessário buscar o grupo de log do lambda, verificar os logs disponíveis (o último é o mais atual), e por fim recuperar o log:

```sh
awslocal logs describe-log-groups \
  --query logGroups[*].logGroupName

awslocal logs describe-log-streams \
  --log-group-name /aws/lambda/exemploapi_funcao
  --query logStreams[*].logStreamName

awslocal logs get-log-events \
  --log-group-name /aws/lambda/exemploapi_funcao
  --log-stream-name 2021/08/30/[LATEST]dface06f
```

A lista dos lambdas configurados pode ser recuperado com:

```sh
awslocal lambda list-functions
```

### API Gateway

O API Gateway é o responsável por permitir a interação com os lambdas através de um endereço HTTP, para isso uma API Rest deve ser criada:

```sh
awslocal apigateway create-rest-api \
  --name exemploapi
```

Para os próximos passos é necessário possuir o `id` da API criada, que pode ser obtido na saída do comando anterior ou listando todas as APIs:

```sh
awslocal apigateway get-rest-apis
```

Para associar um lambda é necessário obter o `id` do caminho também, o qual pode ser verificado com:

```sh
awslocal apigateway get-resources \
  --rest-api-id mea14qi3dw
```

Um novo caminho pode ser criado com:

```sh
awslocal apigateway create-resource \
  --rest-api-id mea14qi3dw \
  --parent-id gv27z1cb9l \
  --path-part caminho
```

Também é necessário informar os métodos que devem ser aceitos em cada caminho:

```sh
awslocal apigateway put-method \
  --rest-api-id mea14qi3dw \
  --resource-id 6g97u23fj2 \
  --http-method GET \
  --authorization-type NONE
```

A associação do lambda com a requisição do caminho em determinado método pode ser feita com:

```sh
awslocal apigateway put-integration \
  --rest-api-id mea14qi3dw \
  --resource-id 6g97u23fj2 \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:exemploapi_funcao \
  --credentials arn:aws:iam::000000000000:role/exemploapi_lambda
```

Para publicar é necessário fazer um deploy:

```sh
awslocal apigateway create-deployment \
  --rest-api-id mea14qi3dw \
  --stage-name main
```

No LocalStack, o API Gateway pode ser acessado através da URL base `http://localhost:4566/restapis/<api_id>/<stage_name>/_user_request_`, exemplo de requisição usando o [HTTPie](https://httpie.io/):

```sh
http -v GET http://localhost:4566/restapis/mea14qi3dw/main/_user_request_/caminho
```

## Deploy com Terraform

Outra opção de deploy é com o Terraform. Para guardar o estado dos recursos criados e permitir a execução do Terraform de locais diferentes é necessário criar um [bucket S3](https://docs.aws.amazon.com/s3/):

```sh
awslocal s3api create-bucket \
  --bucket config
```

Após isso é necessário iniciar o Terraform para que ele se configure utilizando o bucket S3:

```sh
terraform init
```

As configurações dos módulos pode ser copiada com:

```sh
cp config.tfvars.example config.tfvars
```

Após isso é possível verificar o que será criado ou aplicar as alterações com:

```sh
terraform plan -var-file=config.tfvars
terraform apply -var-file=config.tfvars
```
