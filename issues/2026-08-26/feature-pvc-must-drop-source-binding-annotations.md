# Feature PVC must drop source binding annotations

## Observed

Even without `spec.volumeName`, the cloned PVC retained source-controller
annotations such as `pv.kubernetes.io/bind-completed` and
`volume.kubernetes.io/selected-node`. Kubernetes treated the new claim as
already bound while it had no volume reference, immediately setting it to
`Lost`.

## Resolution

Remove all source binding, selected-node, and storage-provisioner annotations
when generating a cloned PersistentVolumeClaim. The provisioner must create a
fresh binding for each feature namespace.

## Verification

Generate and apply a template from a bound source PVC. The feature claim must
become `Bound` to a different PV without retaining source binding annotations.
