#!/usr/bin/env bash
set -euo pipefail

# EP-BRAND-007 release gate.  The actual cluster lifecycle remains in the
# deploy repository's published-artifact harness; this script is the bootstrap
# repository's canonical entry point and policy boundary.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_ROOT="${ENVPLANE_WORKSPACE_ROOT:-$(cd "$ROOT/.." && pwd)}"
DEPLOY_HARNESS="${ENVPLANE_DEPLOY_HARNESS:-$WORKSPACE_ROOT/deploy/scripts/published-artifact-e2e.sh}"
LOG_DIR="${ENVPLANE_E2E_LOG_DIR:-$(mktemp -d)}"
LOG_DIR_OWNED=false
if [[ -z "${ENVPLANE_E2E_LOG_DIR:-}" ]]; then
  LOG_DIR_OWNED=true
fi
KEEP_LOGS="${ENVPLANE_E2E_KEEP_LOGS:-false}"

mkdir -p "$LOG_DIR"
cleanup() {
  if [[ "$KEEP_LOGS" != true ]]; then
    if [[ "$LOG_DIR_OWNED" == true ]]; then rm -rf "$LOG_DIR"; fi
  else
    printf 'E2E phase logs retained at %s\n' "$LOG_DIR" >&2
  fi
}
trap cleanup EXIT

die() { KEEP_LOGS=true; printf 'EP-BRAND-007: %s\n' "$*" >&2; exit 1; }
phase() { printf '\n==> EP-BRAND-007 phase: %s\n' "$*"; }

# Resolve canonical names first.  Legacy names are deliberately accepted only
# at this boundary so existing operators can run the gate during migration.
resolve_alias() {
  local canonical="$1" legacy="$2" value
  value="${!canonical:-}"
  if [[ -n "$value" ]]; then
    printf '%s' "$value"
    return
  fi
  value="${!legacy:-}"
  if [[ -n "$value" ]]; then
    printf 'warning: %s is deprecated; use %s (value redacted)\n' "$legacy" "$canonical" >&2
  fi
  printf '%s' "$value"
}

if [[ "${1:-}" == "--contract" ]]; then
  ENVPLANE_BRAND_GATE_CANONICAL=canonical
  ENVPILOT_BRAND_GATE_CANONICAL=legacy
  [[ "$(resolve_alias ENVPLANE_BRAND_GATE_CANONICAL ENVPILOT_BRAND_GATE_CANONICAL)" == canonical ]] || die "canonical alias did not win"
  unset ENVPLANE_BRAND_GATE_CANONICAL
  [[ "$(resolve_alias ENVPLANE_BRAND_GATE_CANONICAL ENVPILOT_BRAND_GATE_CANONICAL)" == legacy ]] || die "legacy fallback did not resolve"
  printf 'EP-BRAND-007 alias precedence contract is valid\n'
  exit 0
fi

require_command() { command -v "$1" >/dev/null 2>&1 || die "required command is missing: $1"; }

phase "resolve canonical release inputs (canonical wins over legacy)"
E2E_CONTEXT="$(resolve_alias ENVPLANE_E2E_CONTEXT ENVPILOT_E2E_CONTEXT)"
VALUES_FILE="$(resolve_alias ENVPLANE_E2E_VALUES_FILE ENVPILOT_E2E_VALUES_FILE)"
CHART_N_MINUS_1="$(resolve_alias ENVPLANE_E2E_CHART_N_MINUS_1 ENVPILOT_E2E_CHART_N_MINUS_1)"
CHART_N="$(resolve_alias ENVPLANE_E2E_CHART_N ENVPILOT_E2E_CHART_N)"
[[ -n "$E2E_CONTEXT" ]] || die "set ENVPLANE_E2E_CONTEXT (or migration fallback ENVPILOT_E2E_CONTEXT)"
[[ -f "$VALUES_FILE" ]] || die "values file does not exist: $VALUES_FILE"
[[ "$CHART_N_MINUS_1" == oci://* && "$CHART_N" == oci://* ]] || die "N-1 and N chart refs must be published OCI references"

for bin in bash helm kubectl curl jq; do require_command "$bin"; done
[[ -x "$DEPLOY_HARNESS" ]] || die "published artifact harness is not executable: $DEPLOY_HARNESS"

phase "verify published OCI artifacts before touching the cluster"
helm show chart "$CHART_N_MINUS_1" >/dev/null || die "cannot resolve published N-1 OCI chart"
helm show chart "$CHART_N" >/dev/null || die "cannot resolve published N OCI chart"

# The deploy harness keeps its historical variable names for compatibility.
# Values are passed through the environment, never echoed.
export ENVPILOT_E2E_CONTEXT="$E2E_CONTEXT"
export ENVPILOT_E2E_VALUES_FILE="$VALUES_FILE"
export ENVPILOT_E2E_CHART_N_MINUS_1="$CHART_N_MINUS_1"
export ENVPILOT_E2E_CHART_N="$CHART_N"

# Forward non-secret optional inputs as well.  This keeps the gate useful for
# existing fixtures while making ENVPLANE_* the only names operators need to
# learn.  Secret-bearing values are intentionally not copied or printed here.
for suffix in NAMESPACE RELEASE API_PORT UI_PORT PROJECT_ID ENVIRONMENT_ID PROJECT_PAYLOAD ENVIRONMENT_PAYLOAD ROLLBACK_REVISION; do
  canonical="ENVPLANE_E2E_${suffix}"
  legacy="ENVPILOT_E2E_${suffix}"
  if [[ -n "${!canonical:-}" ]]; then export "$legacy=${!canonical}"; fi
done
if [[ -n "${ENVPLANE_E2E_SCM_TOKEN_FILE:-}" ]]; then export ENVPILOT_E2E_SCM_TOKEN_FILE="$ENVPLANE_E2E_SCM_TOKEN_FILE"; fi

phase "fresh install, runtime authentication, resource scan and Helm Direct bootstrap"
log_file="$LOG_DIR/fresh-install.log"
if ! "$DEPLOY_HARNESS" >"$log_file" 2>&1; then
  # Do not retain or print raw harness output: it may contain an operator-
  # supplied SCM credential or a generated bootstrap value. Keep only a safe
  # phase summary for diagnosis.
  redacted="$LOG_DIR/fresh-install.redacted.log"
  grep -Eiv 'token|secret|password|credential|authorization|bearer|registration|project-config' "$log_file" >"$redacted" || true
  rm -f "$log_file"
  die "fresh install/upgrade/rollback harness failed; redacted phase log: $redacted"
fi

phase "verify no known credential material entered the phase log"
for secret in "${ENVPLANE_E2E_SCM_TOKEN:-}" "${ENVPILOT_E2E_SCM_TOKEN:-}"; do
  if [[ -n "$secret" ]] && grep -Fq -- "$secret" "$log_file"; then
    die "phase log contains supplied credential material; refusing a passing release gate"
  fi
done
if grep -Eiq 'registrationToken|bootstrapSecretCommand|project-config-token|authorization:[[:space:]]*bearer|clientSecret' "$log_file"; then
  die "phase log contains raw credential-shaped output; refusing a passing release gate"
fi

phase "release gate passed"
printf 'fresh install, published OCI upgrade, rollback, runtime auth, resource scan, Helm Direct, cleanup and secret-redaction checks passed\n'
