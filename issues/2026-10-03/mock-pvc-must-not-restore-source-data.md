# Empty mock PVC must not retain restore or volume selection fields

## Finding and implementation prompt
The mock PVC generator detached volumeName and binding annotations but retained
dataSource, dataSourceRef and selector. A source snapshot or PVC reference could
therefore copy data instead of provisioning the promised empty feature storage.
Strip those fields only for explicit mock selections. Preserve storage class,
size and access modes; never mutate the source snapshot or source workload.

## Local fix and regression
The generator now removes all three fields for mock PVCs. Regression includes
snapshot and claim references, selectors, storage settings and source immutability.
Other explicit strategies retain their existing behavior. Live base PVCs are not
modified by this patch. Runtime acceptance requires the updated bootstrap library.
