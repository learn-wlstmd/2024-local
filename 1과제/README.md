## 0. 참조 명령어
```
sudo yum update -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo yum install jq -y

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

sudo yum install wget -y

sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

kubectl version --client
eksctl version
```

## 1. ECR 이미지 생성 및 Push
```
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com
docker build -t golang-api .
docker tag golang-api:latest AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest
docker push AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest

docker run -e AWS_ACCESS_KEY_ID=value -e AWS_SECRET_ACCESS_KEY=value 362708816803.dkr.ecr.ap-northeast-2.amazonaws.com/go-db:latest
```

## 2. EKS 클러스터 생성
```
eksctl create cluster --name go-api --region ap-northeast-2 --nodegroup-name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 2 --node-private-networking --vpc-private-subnets=subnet-05ac0f737aa2724d8,subnet-0973a5f8cd1bd4243
```


## 3. EC2 노드 그룹 생성
```
eksctl create nodegroup --cluster go-api --name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 2 --region ap-northeast-2
```


## 4. Fargate 노드 그룹 생성하기
```
eksctl get fargateprofile --cluster go-api --name go-api-fg -o yaml
eksctl delete fargateprofile --cluster go-api --name go-api-fg
eksctl get fargateprofile --cluster go-api

eksctl create fargateprofile \
  --cluster go-api \
  --name go-api-fg \
  --namespace ec2-fargate \
  --region ap-northeast-2 \
  --labels app=fargate-app
```

## 5. Ingress ALB Controller 설치
```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region=ap-northeast-2 --cluster=go-api --approve

eksctl create iamserviceaccount \
  --cluster=go-api \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::362708816803:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=go-api \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

kubectl get deployment -n kube-system aws-load-balancer-controller
```

## 6. namespace 생성
```
kubectl create namespace fargate 
kubectl create namespace ec2
kubectl create namespace ec2-fargate
```

## 7. ElastiCache 참조 링크
```
https://medium.com/classmethodkorea/aws-%EC%9E%85%EB%AC%B8-%EC%8B%9C%EB%A6%AC%EC%A6%88-amazon-elasticache%ED%8E%B8-e2413a3d35d8
```

## 8. 1과제 참조 Golang 코드
```
https://github.com/cloud-daeyang/golang-app-with-documentDB-and-elastiCache
```

## 9. Secret Manager
```
aws secretsmanager create-secret --name "/secrets/skills/app" \
--description "MongoDB and Redis credentials for my app" \
--secret-string '{"mongoUri":"mongodb://wlstmd:cloud24admin!!@docdb-2024-03-22-00-22-46.cluster-cxytji5957dw.ap-northeast-2.docdb.amazonaws.com:27017/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false","redisAddr":"test-ec-tctbtd.serverless.apn2.cache.amazonaws.com:6379"}' \
--region ap-northeast-2

aws secretsmanager update-secret --secret-id "/secrets/skills/app" \
--secret-string '{"mongoUri":"새로운_mongoUri_정보","redisAddr":"새로운_redisAddr_정보"}' \
--region ap-northeast-2


aws secretsmanager get-secret-value --secret-id "/secrets/skills/app" --region ap-northeast-2
```

## 10. DocumentDB Error Solution
```
sudo yum remove mongodb-mongosh
sudo yum install mongodb-mongosh-shared-openssl3
```
