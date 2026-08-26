# Generated metadata must quote YAML special strings

## Observed

The deterministic YAML renderer emitted generated metadata values such as
`envplane.io/managed: true` without quotes. YAML decoders interpreted the
value as a boolean, while Kubernetes labels and annotations require strings.
Direct application of generated manifests failed before any resource could be
created.

## Resolution

Quote boolean- and null-like strings during deterministic YAML rendering, so
generated ownership labels and annotations remain strings.

## Verification

Render templates and apply them with `kubectl apply -k`. Values including
`true`, `false`, `null`, and `~` must remain quoted strings.
