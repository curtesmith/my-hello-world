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
aws s3 cp terraform.tfstate s3://travis-builds-curtesmith/latest/
aws s3 cp terraform.tfstate s3://travis-builds-curtesmith/archive/$TRAVIS_BUILD_NUMBER/

#get kubectl and add to bin folder
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.7.0/bin/linux/amd64/kubectl && \
    chmod +x kubectl && sudo mv kubectl /usr/local/bin/

#configure kubectl and deploy the metrics server
echo "region:" $(terraform output region)
echo "cluster_name:" $(terraform output cluster_name)
#aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name) --role-arn 
echo "view configuration"
kubectl config view

echo "replace config"
terraform output kubectl_config > ~/.kube/config

echo "view updated configuration"
kubectl config view

echo "get identity"
aws sts get-caller-identity

echo "testing get svc"
kubectl get svc

echo "apply metrics components"
#wget -O v0.3.6.tar.gz https://codeload.github.com/kubernetes-sigs/metrics-server/tar.gz/v0.3.6 && tar -xzf v0.3.6.tar.gz
#kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml