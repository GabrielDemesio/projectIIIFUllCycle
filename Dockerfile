# Estágio 1: Compila a aplicação Go
FROM golang:1.24-alpine as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

# Copia todos os ficheiros do projeto, incluindo a pasta de migrations
COPY . .

RUN go install github.com/google/wire/cmd/wire@latest
RUN go generate ./...

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/ordersystem

# Estágio 2: Cria a imagem final
FROM alpine:latest

WORKDIR /app

# Copia o binário compilado
COPY --from=builder /app/main .
# Copia a pasta de migrations para a imagem final (caminho corrigido)
COPY --from=builder /app/db/migrations ./db/migrations

COPY .env .

EXPOSE 8080
EXPOSE 50051
EXPOSE 8081

CMD ["./main"]
