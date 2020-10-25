#!/bin/bash
#install terraform

curl -sLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip
unzip /tmp/terraform.zip -d /tmp
mv /tmp/terraform ~/bin
export PATH="~/bin:$PATH"


#install awscli
pyenv global 3.7.1
pip install -U pip
pip install awscli

#retreive latest tfstate
aws s3 cp s3://travis-builds-curtesmith/latest/terraform.tfstate terraform

#apply infrastructue updates from main.tf
cd terraform
terraform init

terraform plan -out=main.plan

terraform apply main.plan

#retain terraform.tfstate
cd ..

aws s3 cp terraform/terraform.tfstate s3://travis-builds-curtesmith/latest/
aws s3 cp terraform/terraform.tfstate s3://travis-builds-curtesmith/archive/$TRAVIS_BUILD_NUMBER/
