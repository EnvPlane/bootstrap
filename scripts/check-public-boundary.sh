#!/usr/bin/env bash
set -euo pipefail

test -f manifest.go
test -f docs/module-ownership.md
GOTOOLCHAIN=local GOSUMDB=off GOPROXY=off go list ./...
