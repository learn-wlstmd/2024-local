## 1. ECR 이미지 생성 및 Push
```
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com
docker build -t golang-api .
docker tag golang-api:latest AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest
docker push AWS계정ID.dkr.ecr.ap-northeast-2.amazonaws.com/golang-api:latest
```

## 2. EKS 클러스터 생성
```
eksctl create cluster --name go-api --region ap-northeast-2 --nodegroup-name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 2 --node-private-networking --vpc-private-subnets=subnet-05ac0f737aa2724d8,subnet-0973a5f8cd1bd4243
```


## 3. EC2 노드 그룹 생성
```
eksctl create nodegroup --cluster go-api --name go-api-node --node-type t3.medium --nodes-min 2 --nodes-max 2
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