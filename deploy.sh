#!/bin/bash
set -o errexit -o nounset

cd terraform

terraform plan

terraform apply