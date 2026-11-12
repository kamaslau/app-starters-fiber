# app-starters-fiber

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![GitHub top language](https://img.shields.io/github/languages/top/kamaslau/app-starters-fiber)
![GitHub go.mod Go version](https://img.shields.io/github/go-mod/go-version/kamaslau/app-starters-fiber)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/kamaslau/app-starters-fiber)
![Repository size](https://img.shields.io/github/repo-size/kamaslau/app-starters-fiber?color=56BEB8)
![GitHub Repo stars](https://img.shields.io/github/stars/kamaslau/app-starters-fiber)

A Go app starter on [Fiber](https://docs.gofiber.io/): routing, config, GORM migrations, a Redis cache, a NATS queue and a health check, already wired to each other. Start here when the service is small and its shape is still open.

Make sure that you have [Golang](https://go.dev/) installed already.

- [GORM](https://gorm.io/docs/) as ORM, to [operate with Postgre database](https://gorm.io/docs/connecting_to_the_database.html#PostgreSQL)
- [Redis](https://redis.io/docs/latest/) as Cache, [etcd](https://etcd.io/docs/latest/) can also be a good choice
- [NATS](https://docs.nats.io/) as Message Queue
- [InfluxDB](https://docs.influxdata.com/) for Time Series Data (logs, etc.)
- ~~[GQLGen](https://gqlgen.com/) as GraphQL~~

## [🇨🇳 Optional] Setup Mirror for Mainland China

You can safely skip this part if not approaching the internet from within mainland China.

```bash
go env -w GOPROXY=https://goproxy.io,direct # Official
go env -w GOPROXY=https://goproxy.cn,direct # QiniuCloud/七牛云

go env GOPROXY # Double check
```

## Service Endpoints

### RESTful

- Root: http://127.0.0.1:3000/api/v1/
- Health Check: http://127.0.0.1:3000/health
- Demo with _Posts_ model: http://127.0.0.1:3000/api/v1/post

### GraphQL (TODO)

- Root: [http://127.0.0.1:3000/graphql/](http://127.0.0.1:3000/graphql/)
- Demo is not available for now

```bash
curl -X POST \
http://127.0.0.1:3000/graphql/ \
-H 'Content-Type: application/json' \
-d '{
  "query": "query { posts { id name } }"
}'
```

## Usage

Create an `app-starters-fiber` database (you can use another name, just config it in the `.env` file) in PostgreSQL/MySQL/MariaDB of yours, then follow these steps below.

```bash
# Create .env file
cp .env.example .env # at least specify a database connection info

# [Optional] Update dependencies
go get -u ./...

# Install Dependencies
go mod tidy
```

### Run

Without live-reloading

```bash
# Main.main
go run ./src/cmd/main.go

# Tools (database migration, etc.)
go run ./src/cmd/tools/database.go # w/o seeding
go run ./src/cmd/tools/database.go -s # w/ seeding
go run ./src/cmd/tools/database.go --Seeding
```

With live-reloading (via air-verse/air)

```bash
# Install Air
go install github.com/air-verse/air@latest

# Run with
air # Linux/macOS, default
air -c .air.windows.toml # Windows

```

For more detailed instructions, e.g. solutions on working cross OS, checkout [https://manual.kamaslau.com/golang/tools/air.html](https://manual.kamaslau.com/golang/tools/air.html).

### Compile

To make envarionment variables work, a .env file needs to co-exist in the same directory with the executable file compiled.

```bash
go build -o ./tmp/main ./src

```

## Deploy (via docker)

```bash
docker build . -t app-starters-fiber:latest

docker network create app-starters-backend && \
docker stop app-starters-fiber && \
docker rm app-starters-fiber && \
docker run --name app-starters-fiber --network app-starters-backend -p 3000:3000 -d --restart always --net=host app-starters-fiber:latest
```

Make sure that other service components (database, cache, MQ, etc.) are within the same network, e.g.,

```bash
docker network connect app-starters-backend app-starters-fiber
docker network connect app-starters-backend database-xxx
docker network connect app-starters-backend mq-xxx
```

## Use this template

*Use this template* gives you a repository you own, with no history and no link back here — the right shape for
the first commit of a real app. Clone it instead when you want to follow changes to the starter itself;
a repository created from the template never receives them.

## References/Credits

- [Go Fiber: Start Building RESTful APIs on Golang (Feat. GORM)](https://dev.to/percoguru/getting-started-with-apis-in-golang-feat-fiber-and-gorm-2n34)
- [Building a GraphQL Server with Go Backend Tutorial | Getting Started](https://www.howtographql.com/graphql-go/0-introduction/)
