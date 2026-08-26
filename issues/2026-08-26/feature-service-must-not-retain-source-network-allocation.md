# Feature Service must not retain source network allocation

## Observed

The manifest-template generator copied `Service.spec.clusterIP` and related
allocated networking fields from the scanned namespace. Flux then rejected a
feature Service because the requested ClusterIP was already allocated to its
source Service.

## Impact

Feature environment creation stopped before the namespace and workloads could
be created.

## Resolution

Remove source-assigned `clusterIP`, `clusterIPs`, IP-family values,
`healthCheckNodePort`, and per-port `nodePort` fields while generating cloned
Service templates. Kubernetes will allocate fresh values for the feature
environment.

## Verification

Generate a template from a Service with ClusterIP and NodePort fields, then
apply it alongside the source Service. The new Service must be accepted and
receive distinct allocations.
