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
cd terraform

#get kubectl and add to bin folder
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && sudo mv kubectl /usr/local/bin/

#configure kubectl and deploy the metrics server
aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)

cd ..

#install AWS IAM Authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p /usr/local/bin && sudo cp ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

echo "apply update for application and service"
kubectl apply -f deploy.yml
kubectl apply -f services.yml