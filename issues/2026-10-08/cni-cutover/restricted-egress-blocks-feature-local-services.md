# Restricted egress blocks feature-local backend and MySQL on enforcing CNI

Observed during Calico cutover review: the active feature policy permits only
reviewed base namespaces plus DNS. It has no same-namespace peer. The source CNI
did not enforce the policy, so frontend-to-backend and backend-to-MySQL failure
was previously hidden. Calico makes that omission effective.

## Local fix

Restricted-mode generator adds a peer with only `podSelector: {}`. Kubernetes
scopes this peer to the policy namespace; no empty `namespaceSelector` or broad
IP range is added. Approved base and DNS rules remain. Explicit `deny all` mode
still emits an empty egress list; its semantics are not weakened.

Unit tests assert the selector's exact shape and unchanged deny-all behavior.

## Codex implementation prompt

Integrate the local bootstrap fix into the API build without publishing modules
or pushing yet. For the existing frozen environment, use the normal reviewed
compiled GitOps path to update its policy, not a hidden global allow rule.
On the Calico candidate prove same-namespace HTTP/MySQL succeeds and traffic to
an unapproved namespace and external destination is denied. Repeat after Flux
reconciliation and preserve source data/rollback. Do not declare live closure
from generator/unit checks alone.
