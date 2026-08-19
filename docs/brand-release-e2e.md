# EP-BRAND-007 release gate

`scripts/brand-release-e2e.sh` is the Bootstrap entry point for the EnvPlane
branding migration release gate. It delegates the cluster lifecycle to the
existing `deploy/scripts/published-artifact-e2e.sh` harness; no second E2E
framework or cluster fixture is created here.

The gate performs, in order:

1. Resolves canonical `ENVPLANE_E2E_*` inputs. `ENVPILOT_E2E_*` is a migration
   fallback only; when both are set, the canonical value wins.
2. Resolves both immutable N-1 and N chart references from OCI and fails before
   touching Kubernetes if either artifact is unavailable.
3. Runs the existing published lifecycle: fresh install, Agent/Runner runtime
   authentication, resource scan, Helm Direct project bootstrap, N upgrade,
   rollback, health checks and cleanup.
4. Suppresses harness output on failure and rejects logs containing known or
   credential-shaped values. Raw registration/runtime tokens are never printed.

Example (published artifacts and an already-provisioned cluster):

```bash
ENVPLANE_E2E_CONTEXT=bethunder-local \
ENVPLANE_E2E_VALUES_FILE=/path/to/published-values.yaml \
ENVPLANE_E2E_CHART_N_MINUS_1=oci://ghcr.io/EnvPlane/envpilot:0.3.136 \
ENVPLANE_E2E_CHART_N=oci://ghcr.io/EnvPlane/envpilot:0.3.137 \
ENVPLANE_E2E_SCM_TOKEN_FILE=/path/to/operator-token-file \
  ./scripts/brand-release-e2e.sh
```

The command intentionally does not create a cluster, publish artifacts, or
push a Git change. Set `ENVPLANE_E2E_KEEP_LOGS=true` when an operator needs the
redacted phase log path after a failure.
