#!/bin/bash
set -ex

GIT_COMMIT_SHA=$(git rev-parse HEAD)

eval $(aws ecr get-login --no-include-email --region us-east-1)
docker build -f Dockerfile -t test-gig-$1:$GIT_COMMIT_SHA .
docker tag test-gig-$1:$GIT_COMMIT_SHA 569325332953.dkr.ecr.us-east-1.amazonaws.com/test-gig-$1:$GIT_COMMIT_SHA
docker push 569325332953.dkr.ecr.us-east-1.amazonaws.com/test-gig-$1:$GIT_COMMIT_SHA

# create the configmap
kubectl delete configmap test-gig-configmap -n=test-gig-$2
touch ./deploy/test-gig-$2/.config
kubectl create configmap test-gig-configmap --from-env-file=./deploy/test-gig-$2/.config -n=test-gig-$2

# create the secrets
kubectl delete secret test-gig-secrets -n=test-gig-$2
touch ./deploy/test-gig-$2/.env
kubectl create secret generic test-gig-secrets --from-env-file=./deploy/test-gig-$2/.env -n=test-gig-$2

# push to prod
cp ./deploy/test-gig-$1-deployment.yaml ./deploy/test-gig-$1-deployment-tmp.yaml
sed -i.bak "s/__GIT_COMMIT_SHA__/$GIT_COMMIT_SHA/" ./deploy/test-gig-$1-deployment-tmp.yaml
rm ./deploy/test-gig-$1-deployment-tmp.yaml.bak

kubectl apply -f ./deploy/test-gig-$2/test-gig-$1-service.yaml -n=test-gig-$2
kubectl apply -f ./deploy/test-gig-$1-deployment-tmp.yaml -n=test-gig-$2

rm ./deploy/test-gig-$1-deployment-tmp.yaml
