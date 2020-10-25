#!/bin/bash

cd terraform
terraform init
cp ~/terraform.tfstate .

terraform plan -out=main.plan

terraform apply main.plan