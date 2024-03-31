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
eksctl create cluster --name go-api --region ap-northeast-2 --nodegroup-name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 2 --node-private-networking --vpc-private-subnets=subnet-05ac0f737aa2724d8,subnet-0973a5f8cd1bd4243 // 서브넷 변경
```


## 3. EC2 노드 그룹 생성 및
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
  --region=ap-northeast-2 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
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
kubectl create namespace ec2-fargate
```

## 7. ElastiCache 참조 링크
```
https://velog.io/@amoeba25/Amazon-Linux-2023-%EC%84%9C%EB%B2%84%EC%97%90%EC%84%9C-Redis-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0

https://velog.io/@godqhrals/AWS-ElasticBeanstalk%EC%97%90-ElastiCache%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%B4-Redis-%EC%97%B0%EA%B2%B0%ED%95%98%EA%B8%B0
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

## 11. Server Size Solution
```
sudo docker image prune -a

sudo docker system prune -a

sudo docker volume prune

df -h
```

## 12. VPC 엔드포인트 세팅
```
https://velog.io/@sororiri/%ED%94%84%EB%9D%BC%EC%9D%B4%EB%B9%97-%EC%84%9C%EB%B8%8C%EB%84%B7%EC%97%90%EC%84%9C-ECR-%EC%97%90-%EC%A0%91%EC%86%8D%ED%95%A0-%EB%95%8C-%ED%95%84%EC%9A%94%ED%95%9C-VPC-%EC%97%94%EB%93%9C%ED%8F%AC%EC%9D%B8%ED%8A%B8-%EC%84%A4%EC%A0%95-feat-terraform
```

## 13. MongoDB Install
```
https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-amazon/
```

## 14. Docker 플랫폼 호환성 관련 에러 Solution
```
https://velog.io/@msung99/Docker-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EB%B9%8C%EB%93%9C-%ED%94%8C%EB%9E%AB%ED%8F%BC-%ED%98%B8%ED%99%98%EC%84%B1-%EA%B4%80%EB%A0%A8-%EC%97%90%EB%9F%AC-linuxamd64
```

## 15. k8s alb solution
```
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

## 16. Base64
```
https://www.convertstring.com/ko/EncodeDecode/Base64Decode
```

## 17. Docker ECR Login Solution
```
sudo usermod -aG docker $USER


sudo systemctl start docker


sudo aws ecr get-login-password --region ap-northeast-2 | sudo docker login --username AWS --password-stdin 362708816803.dkr.ecr.ap-northeast-2.amazonaws.com
```
