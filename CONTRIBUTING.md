# Contributing

This repository is one starter of the app-starters family: Go on [Fiber](https://docs.gofiber.io/), with GORM, Redis, NATS and InfluxDB already wired to each other.

Default port: 3000. It comes from `.env` (`PORT`); nothing here hardcodes it.

## The shape a change has to keep

A starter, not a framework: four dependencies wired correctly, one demo model, and nothing else. The value is that the wiring is already done — not that it is extensive.

The test for any change: could someone who has never seen this repository have `/health` answering from the README alone, and know which file to open to add a route?

## Pull requests

- **`drivers.InitDrivers()` keeps failing at startup.** A dependency that is unreachable has to stop the process while someone is watching, not surface three requests later as a 500 on one route.
- **`src/main.go` stays the only entry point.** Migrations live in `src/tools/database.go` and run as their own binary; a server that migrates on boot races every other instance of itself.
- **Configuration comes from `.env`, and the image does not contain it.** `docker run --env-file .env` is the contract; a baked `.env` turns a missing variable into a rebuild.
- **The README is English.** Chinese belongs only under a *Notes for deployments in China* section — and this repository has one, because module proxies and registry mirrors are the two failures that dominate here.
- **`Verify` has to keep proving something.** Any change in behaviour updates the command in that section.
- **Commits**: imperative subject, one concern per commit. `fix: build ./src, not ./src/cmd` is the shape. `update` is not.

## Adding a starter

Open an issue on [infra-blocks](https://github.com/kamaslau/infra-blocks) before writing anything — the family is meant to stay small, and two starters for the same framework is a maintenance cost rather than a choice.

If it is accepted:

1. Repository named `app-starters-<framework>`, MIT license, description in the form *what it is + what it gives you*.
2. README with the sections used across the family: title and one-line purpose, Service Endpoints, Usage, Verify, Why this shape, Use this template.
3. `is_template` enabled, and a row in the index under *Not in this list*.

## Reporting a problem

Open an issue with four things: the command you ran, what you expected, what happened, and the output of `go run ./src`. Without the last one, most reports turn into guesswork.

---

Part of the app-starters family · MIT
