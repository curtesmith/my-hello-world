#!/bin/bash
curl -sLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
unzip /tmp/terraform.zip -d /tmp
mv /tmp/terraform ~/bin
export PATH="~/bin:$PATH"

pyenv global 3.7.1
pip install -U pip
pip install awscli

aws s3 cp s3://travis-builds-curtesmith/latest/terraform.tfstate terraform

cd terraform
terraform init

terraform plan -out=main.plan

terraform apply main.plan

cd ..

aws s3 cp terraform/terraform.tfstate s3://travis-builds-curtesmith/latest/
aws s3 cp terraform/terraform.tfstate s3://travis-builds-curtesmith/archive/$TRAVIS_BUILD_NUMBER/
