# Build Stage
FROM golang:1.22-alpine AS builder

RUN apk update && apk add --no-cache git

WORKDIR /app

# Copy go.mod and run go mod tidy to generate go.sum
COPY go.mod .
RUN go mod tidy

# Copy the rest of the source code
COPY . .

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -o /app/binary application/*.go

# Final Stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

COPY --from=builder /app/binary .
COPY --from=builder /app/files/migrations ./files/migrations
COPY --from=builder /app/files/secrets ./files/secrets

EXPOSE 8080

ENTRYPOINT ["./binary"]
