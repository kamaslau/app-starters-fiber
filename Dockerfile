ARG IMAGE_TAG="alpine"
FROM golang:${IMAGE_TAG} AS base
# FROM golang:alpine AS base
WORKDIR /app
# [Optional] Setup Mirror for Mainland China
# RUN go env -w GOPROXY=https://goproxy.cn,direct # 七牛云
# RUN go env GOPROXY

FROM base AS builder
COPY . .
RUN go mod tidy
RUN go mod verify
# The entry point is src/main.go, so the package to build is ./src
RUN go build -o ./tmp/main ./src

FROM alpine:3 AS runner
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/tmp/main ./main
COPY --from=builder /app/public ./public

# Configuration arrives at run time: docker run --env-file .env …
# Baking .env into the image hides a missing variable until the next rebuild.
EXPOSE 3000

CMD ["./main"]
