## 0. 프론트엔드 CICD 관련 링크
```
https://sharplee7.tistory.com/139
```

## 1. Push 명령어 에러 해결 방안
```
vi ~/.gitconfig 

[credential]
    helper = !aws codecommit credential-helper $@
    UseHttpPath = true
```

## 2. Spring Build
```
./gradlew build
```

## 3. docker platform error solution
```
https://velog.io/@msung99/Docker-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EB%B9%8C%EB%93%9C-%ED%94%8C%EB%9E%AB%ED%8F%BC-%ED%98%B8%ED%99%98%EC%84%B1-%EA%B4%80%EB%A0%A8-%EC%97%90%EB%9F%AC-linuxamd64
```


## 4. IAM 권한
```
AmazonEC2ContainerRegistryPowerUser
AWSCodeCommitPowerUser
```

## 5. Spring Deploy
```
https://developer-heo.tistory.com/48
```
