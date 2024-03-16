## 1. ECR 이미지 생성 및 Push
```
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com
docker build -t golang-api .
docker tag golang-api:latest AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest
docker push 362708816803.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest
```

## 2. EKS 클러스터 생성
```eksctl create cluster --name go-api --region ap-northeast-2 --nodegroup-name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 3 --node-private-networking --vpc-private-subnets=subnet-05ac0f737aa2724d8,subnet-0973a5f8cd1bd4243
```


## 3. EC2 노드 그룹 생성
```eksctl create nodegroup --cluster go-api --name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 3```


## 4. Fargate 노드 그룹 생성하기
```eksctl create fargateprofile --cluster go-api --name go-api-fg --namespace default --region ap-northeast-2```


## 5. label 지정
```kubectl label nodes node-name ec2node=true
kubectl label nodes node-name fargatenode=true
```