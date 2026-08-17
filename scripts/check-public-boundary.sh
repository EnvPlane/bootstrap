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

if [[ -n "${required_go}" ]]; then
  selected_go=""
  # Keep the binary selected by PATH first.  ensure-go.sh may have just
  # placed a hosted/toolcache runtime on PATH; unconditionally preferring
  # /usr/local/go can select an older installation and report a false
  # "no local toolchain" error.
  for candidate in "${go_bin}" /usr/local/go/bin/go; do
    [[ -x "${candidate}" ]] || continue
    if version_ge "$(go_version "${candidate}")" "${required_go}"; then
      selected_go="${candidate}"
      break
    fi
  done

  # GitHub Actions exports GOTOOLCHAIN=go<module-version> in a later step.
  # That value is already validated by ensure-go.sh; retain the PATH binary
  # even when a vendor Go wrapper does not report its version under
  # GOTOOLCHAIN=local (otherwise we falsely reject a usable runtime).
  if [[ -z "${selected_go}" && "${GOTOOLCHAIN:-}" == "go${required_go}" && -x "${go_bin}" ]]; then
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
