#!/usr/bin/env bash
set -euo pipefail

test -f manifest.go
test -f docs/module-ownership.md

required_go="${GO_MIN_VERSION:-}"
if [[ -z "${required_go}" ]]; then
  required_go="$(awk '/^go[[:space:]]/ { print $2; exit }' go.mod)"
fi

version_ge() {
  local current="$1"
  local required="$2"
  local lowest
  lowest="$(printf '%s\n%s\n' "${required}" "${current}" | sort -V | head -n 1)"
  [[ "${lowest}" == "${required}" ]]
}

go_version() {
  local bin="$1"
  GOTOOLCHAIN=local "$bin" version 2>/dev/null | awk '{print $3}' | sed 's/^go//'
}

go_bin="$(command -v go)"
if [[ -x "/usr/local/go/bin/go" ]]; then
  go_bin="/usr/local/go/bin/go"
fi

if [[ -n "${required_go}" ]]; then
  selected_go=""
  if [[ -x "${go_bin}" ]] && version_ge "$(go_version "${go_bin}")" "${required_go}"; then
    selected_go="${go_bin}"
  fi

  if [[ -z "${selected_go}" ]]; then
    if [[ -x "scripts/ensure-go.sh" ]]; then
      GO_MIN_VERSION="${required_go}" GO_VERSION_FILE=go.mod ./scripts/ensure-go.sh
      if [[ -x "/usr/local/go/bin/go" ]] && version_ge "$(go_version /usr/local/go/bin/go)" "${required_go}"; then
        selected_go="/usr/local/go/bin/go"
      fi
    fi
  fi

  if [[ -n "${selected_go}" ]]; then
    GOTOOLCHAIN=local GOSUMDB=off GOPROXY=off "${selected_go}" list -deps ./cmd/...
  else
    echo "::error::No local Go toolchain >= ${required_go} available for public boundary check" >&2
    exit 1
  fi
fi
