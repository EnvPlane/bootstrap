# Broad application policies also select isolated PVC exporters

Status: future generator fixed locally; active Flux snapshot patch owned by parent.

NetworkPolicy permissions union. Feature podSelector:{} allow policies can select
the private exporter and broaden its API-only egress or scraper-only ingress.
Adding a narrow exporter policy alone does not remove other allow policies.

Codex implementation: application allow policies exclude Pods carrying
envplane.io/pvc-exporter via DoesNotExist. Apply consistently to base-to-feature
ingress, feature allow/restricted egress and explicitly allowed base ingress.
Keep deny-all namespace-wide and ordinary workload permissions unchanged.

Acceptance: generator tests cover all allow modes and unchanged deny-all. Parent
must persist the same selector exclusion in the active candidate Flux snapshot,
then test actual CNI denies; don't claim API-only while broad policies still select
the exporter. Source data, source policies and namespace ownership remain untouched.
