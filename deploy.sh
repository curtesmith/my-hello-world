#!/bin/bash
pyenv global 3.7.1
pip install -U pip
pip install awscli

aws s3 sync s3://travis-builds-curtesmith terraform

cd terraform
terraform init

terraform plan -out=main.plan

terraform apply main.plan

aws s3 sync terraform.tfstate s3://travis-builds-curtesmith/$TRAVIS_BUILD_NUMBER