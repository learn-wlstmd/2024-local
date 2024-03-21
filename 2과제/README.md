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