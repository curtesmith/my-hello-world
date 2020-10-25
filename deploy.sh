#!/bin/bash

cd terraform
terraform init

terraform plan -out=main.plan

terraform apply main.plan