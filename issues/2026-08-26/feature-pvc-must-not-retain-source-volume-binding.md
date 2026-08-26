# Feature PVC must not retain source volume binding

## Observed

A Full environment generated from `demo-backend/backend-data` copied the source
PVC's `spec.volumeName`. The referenced PersistentVolume did not exist for the
new namespace, so Kubernetes marked the feature claim `Lost`.

## Expected

Generated feature PVC manifests are unbound. Data-copy or snapshot behavior is
provided separately by the selected stateful materialization strategy.

## Resolution

Remove `spec.volumeName` while generating `PersistentVolumeClaim` templates and
cover the behavior with a generator test.
