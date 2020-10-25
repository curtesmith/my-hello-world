#!/bin/bash
#set -o errexit -o nounset

cd terraform

terraform plan -out=main.plan

terraform apply main.plan

echo "Setting git user name"
git config user.name curtesmith

echo "Setting git user email"
git config user.email curt.e.smith@gmail.com

echo "Adding git upstream remote"
git remote add upstream "https://git@github.com/curtesmith/my-hello-world.git"

git checkout master

git add .

NOW=$(TZ=America/New_York date)

git commit -m "tfstate: $NOW [ci skip]"

echo "Pushing changes to upstream master"
git push upstream master