# EnvPilot Bootstrap

Cluster onboarding and bootstrap workflow code.

## Scope

- Bootstrap session lifecycle support.
- Manifest template generation and validation.
- Managed resource discovery helpers.
- Cleanup safety checks.
- Agent and runner installation flow support.

## Source Origin

This repository was split from:

- `internal/bootstrap`
- bootstrap-related services in `internal/app`
- bootstrap stores and shared domain/config packages

## Follow-up

Extract the bootstrap service boundary from the control-plane API once the API contracts are stabilized in `contracts`.
