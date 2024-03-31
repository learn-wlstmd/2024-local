# Go 언어 공식 이미지를 기반으로 합니다.
FROM golang:alpine AS builder

# 작업 디렉터리를 설정합니다.
WORKDIR /app

# 애플리케이션 소스 코드를 이미지에 복사합니다.
COPY . .

# 필요한 패키지를 설치합니다. wget도 추가합니다.
RUN apk update && apk add --no-cache git wget

# go.mod 파일이 없다면 go mod init, 있다면 건너뜁니다.
RUN go mod init noah.io/ark/rest || true
# 의존성 다운로드
RUN go mod tidy
# 벤더링(필요한 경우)
RUN go mod vendor

# global-bundle.pem 파일을 다운로드합니다.
RUN wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -P /app

# 애플리케이션을 빌드합니다.
RUN go build -o main .

# 런타임 이미지를 준비합니다.
FROM alpine
WORKDIR /app

# AWS 액세스 키와 시크릿 키를 환경변수로 설정합니다.
ENV AWS_ACCESS_KEY_ID=value \
    AWS_SECRET_ACCESS_KEY=value

# 빌더 스테이지에서 생성된 실행 파일과 global-bundle.pem 파일을 현재 스테이지로 복사합니다.
COPY --from=builder /app/main .
COPY --from=builder /app/global-bundle.pem .

# 필요한 포트를 노출합니다.
EXPOSE 8080

# 애플리케이션을 실행합니다.
CMD ["./main"]


# 바이너리 파일용
# FROM alpine:latest

# WORKDIR /app

# ENV AWS_ACCESS_KEY_ID=value \
#     AWS_SECRET_ACCESS_KEY=value

# COPY go-app .
# COPY global-bundle.pem .

# RUN chmod +x go-app
# EXPOSE 8080
# CMD ["./go-app"]
