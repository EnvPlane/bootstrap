#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="$root/scripts/brand-release-e2e.sh"

bash -n "$script"
contract_output="$($script --contract 2>/dev/null)"
[[ "$contract_output" == *"canonical input contract is valid"* ]] || {
  echo "canonical input executable contract failed" >&2
  exit 1
}
for expected in \
  'ENVPLANE_E2E_CONTEXT' \
  'resolve canonical release inputs' \
  'published OCI artifacts' \
  'fresh install, runtime authentication, resource scan and Helm Direct bootstrap' \
  'phase log contains raw credential-shaped output' \
  'published-artifact-e2e.sh'; do
  grep -Fq "$expected" "$script" || { echo "missing contract marker: $expected" >&2; exit 1; }
done

if grep -Eq 'set -x|printf.*SCM_TOKEN|echo.*SCM_TOKEN|kubectl.*get secret.*-o yaml' "$script"; then
  echo "release gate must not print credentials or Secret payloads" >&2
  exit 1
fi

echo 'EP-BRAND-007 release gate contract is valid'
