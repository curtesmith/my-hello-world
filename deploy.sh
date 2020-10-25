#!/bin/bash
#set -o errexit -o nounset

cd terraform

terraform plan -out=main.plan

terraform apply main.plan