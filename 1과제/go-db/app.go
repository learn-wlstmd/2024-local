package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/go-redis/redis/v8"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	ctx    = context.Background()
	client *mongo.Client
	rdb    *redis.Client
)

type Song struct {
	Title  string `json:"title"`
	Singer string `json:"singer"`
	Text   string `json:"text"`
}

type Secrets struct {
	MongoUri  string `json:"mongoUri"`
	RedisAddr string `json:"redisAddr"`
}

func main() {
	secrets := getSecrets("/secrets/skills/app")
	var err error
	client, err = mongo.Connect(ctx, options.Client().ApplyURI(secrets.MongoUri))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect(ctx)
	rdb = redis.NewClient(&redis.Options{
		Addr: secrets.RedisAddr,
	})

	fs := http.FileServer(http.Dir("./static"))
	http.Handle("/", fs)

	// CORS 미들웨어 적용
	handler := corsMiddleware(http.DefaultServeMux)

	http.HandleFunc("/cd", handleSongs)
	http.HandleFunc("/health", healthCheckHandler)

	log.Println("서버가 시작됩니다. 포트 8080에서 대기 중...")

	log.Fatal(http.ListenAndServe(":8080", handler))
}

func getSecrets(secretName string) Secrets {
	awsRegion := "ap-northeast-2"
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion),
	})
	if err != nil {
		log.Fatal(err)
	}
	svc := secretsmanager.New(sess)
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretName),
	}
	result, err := svc.GetSecretValue(input)
	if err != nil {
		log.Fatal(err)
	}
	var secrets Secrets
	json.Unmarshal([]byte(*result.SecretString), &secrets)

	return secrets
}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
}

// CORS 미들웨어 구현
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		enableCors(&w)
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func handleSongs(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "POST":
		saveSong(w, r)
	case "GET":
		searchSong(w, r)
	default:
		http.Error(w, "Unsupported method", http.StatusMethodNotAllowed)
	}
}

func saveSong(w http.ResponseWriter, r *http.Request) {
	var song Song
	if err := json.NewDecoder(r.Body).Decode(&song); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	collection := client.Database("cd").Collection("songs")
	_, err := collection.InsertOne(ctx, song)
	if err != nil {
		http.Error(w, "Error saving to MongoDB", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func searchSong(w http.ResponseWriter, r *http.Request) {
	title := strings.TrimPrefix(r.URL.Path, "/cd/")
	cachedSong, err := rdb.Get(ctx, title).Result()
	if err == nil {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(cachedSong))
		return
	}
	collection := client.Database("cd").Collection("songs")
	var song Song
	err = collection.FindOne(ctx, bson.M{"title": title}).Decode(&song)
	if err != nil {
		http.Error(w, "Song not found", http.StatusNotFound)
		return
	}
	songJSON, _ := json.Marshal(song)
	rdb.Set(ctx, title, songJSON, 0)
	w.Header().Set("Content-Type", "application/json")
	w.Write(songJSON)
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	response := map[string]int{"status code": 200}
	json.NewEncoder(w).Encode(response)
}
