#!/usr/bin/env bash
set -euo pipefail

test -f manifest.go
test -f docs/module-ownership.md
GOSUMDB=off GOPROXY=off go list ./...
