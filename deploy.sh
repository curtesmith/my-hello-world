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
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && sudo mv kubectl /usr/local/bin/
#curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.7.0/bin/linux/amd64/kubectl && \
#    chmod +x kubectl && sudo mv kubectl /usr/local/bin/

#configure kubectl and deploy the metrics server
echo "region:" $(terraform output region)
echo "cluster_name:" $(terraform output cluster_name)
aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)
echo "view configuration"
kubectl config view

echo "display config file"
cat ~/.kube/config

echo "replace config"
terraform output kubectl_config > ~/.kube/config

echo "view updated configuration"
kubectl config view

echo "get identity"
aws sts get-caller-identity

#install AWS IAM Authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p /usr/local/bin && sudo cp ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
aws-iam-authenticator help

echo "*** testing get svc ***"
kubectl get svc

echo "apply metrics components"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml

echo "apply dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml


echo "create the ClusterRoleBinding resource"
kubectl apply -f https://raw.githubusercontent.com/hashicorp/learn-terraform-provision-eks-cluster/master/kubernetes-dashboard-admin.rbac.yaml

echo "apply update for application and service"
kubectl apply -f deploy.yml
kubectl apply -f service.yml