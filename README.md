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
go run ./src

# Tools (database migration, etc.)
go run ./src/tools/database.go # w/o seeding
go run ./src/tools/database.go -s # w/ seeding
go run ./src/tools/database.go --Seeding
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

## Verify

```bash
curl -s http://127.0.0.1:3000/health
# {"status":"ok","time":{"timezone":"…","offset":…,"unix":…}}
```

`status: ok` means the process is listening and routing. The rest of the app needs more than that: `/api/v1/post` goes through GORM to the database, so a `500` there with a healthy `/health` is a connection string, not a route.

```bash
curl -s http://127.0.0.1:3000/api/v1/post | head -c 200
```

An empty array is a working chain — database reached, table empty. `dial tcp …: connect: connection refused` in the log means `DB_DSN` points at a database that is not running, which `/health` will not tell you.

## Why this shape

Four dependencies — database, Redis, NATS, InfluxDB — are wired in `drivers.InitDrivers()`, in that order, because a starter that ships a `Post` model with no cache and no queue is a starter every project immediately edits. `InitDrivers` fails loudly at startup rather than lazily on first use: the failure you want is at boot, while you are still watching, not three requests later.

Fiber v3 rather than v2 is deliberate: the handler signature (`func(c fiber.Ctx) error`) and the middleware model are what a new project will be built against for the next few years, and a starter pinned to the old major teaches the wrong API.

The database tooling is a second binary (`src/tools/database.go`), not a flag on the server. Migrations run in CI, on a deploy host, or by hand during a handover — never as a side effect of a web process starting, which is how two instances race the same migration.

`src/main.go` is the only entry point, and it is four calls: load env, init drivers, mount routes, listen. Everything else is in `internal/`, which is what stops the directory from becoming a debate.

## Deploy (via docker)

```bash
docker build . -t app-starters-fiber:latest

docker network create app-starters-backend && \
docker stop app-starters-fiber 2>/dev/null; \
docker rm app-starters-fiber 2>/dev/null; \
docker run --name app-starters-fiber \
  --network app-starters-backend \
  --env-file .env \
  -p 3000:3000 -d --restart unless-stopped \
  app-starters-fiber:latest
```

The image does not contain `.env`: configuration is passed at run time with `--env-file`, so a missing variable is visible in `docker run` rather than frozen into a layer. `--net=host` is not used — on Docker Desktop it does not publish the port to the host at all, and on Linux it makes `-p` a no-op that silently does nothing.

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
