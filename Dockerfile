FROM golang:1.24-alpine as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go install github.com/google/wire/cmd/wire@latest

RUN go generate ./...

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/ordersystem

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .

COPY .env .

EXPOSE 8080
EXPOSE 50051
EXPOSE 8081

CMD ["./main"]