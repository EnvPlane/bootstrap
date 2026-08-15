# EnvPlane Bootstrap

Cluster onboarding workflow for [EnvPlane](https://envplane.dev). It supports
the safe transition from an unregistered Kubernetes target to a managed
environment with Agent and Runner components.

## Responsibilities

- Manage bootstrap session lifecycle.
- Generate and validate installation manifests.
- Discover managed resources safely.
- Enforce cleanup and replay protections.
- Support Agent and Runner installation flows.

## Development

```bash
go test ./...
go vet ./...
make test
make lint
```

Production onboarding is initiated through the authenticated control-plane API
or frontend and reconciled by the deployment layer.

## Security

Bootstrap credentials are one-time or short-lived values. Pass them through
managed Secrets, never log them, and never commit them to manifests or examples.

## Related components

- [Control Plane](https://github.com/EnvPlane/control-plane)
- [Agent](https://github.com/EnvPlane/agent)
- [Runner](https://github.com/EnvPlane/runner)
- [Deploy](https://github.com/EnvPlane/deploy)

## Status

Private EnvPlane platform component under active development.
