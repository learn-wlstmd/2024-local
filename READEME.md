## 1. ECR 이미지 생성 및 Push

$ aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com
$ docker build -t golang-api .
$ docker tag golang-api:latest AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest
$ docker push 362708816803.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest


## 2 EKS 클러스터 생성
$ eksctl create cluster --name go-api --region ap-northeast-2 --nodegroup-name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 3 --node-private-networking --vpc-private-subnets=subnet-05ac0f737aa2724d8,subnet-0973a5f8cd1bd4243
$


## 3. Fargate 프로필 설정 : EKS 클러스터에 Fargate 프로필을 추가합니다. 이는 EKS 클러스터와 Fargate를 연결하는 역할을 한다.
$ eksctl create fargateprofile --cluster go-api --name go-api --namespace default --region ap-northeast-2
$


## 4. EC2 Worker Node 및 Cluster AutoScaler 설정 : EC2 기반 Worker Node 그룹 생성 명령어
$ eksctl create nodegroup --cluster go-api --name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 20 --region ap-northeast-2
$

## 5. Golang API Deployment 및 Service 설정 : api-deployment.yaml 파일의 이미지 경로를 업데이트