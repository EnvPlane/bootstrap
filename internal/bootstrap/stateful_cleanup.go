package bootstrap

import "github.com/envplane/contracts/domain"

// ShouldDeleteStatefulResource is deliberately plan-driven. It can remove a
// feature-owned target only; source PVCs, snapshots and databases are never
// eligible, even when they share labels with the feature.
func ShouldDeleteStatefulResource(plan domain.StatefulExecutionPlan, resource domain.ResourceSnapshot) bool {
	return plan.CanDeleteTarget(resource.Kind, resource.Namespace, resource.Name)
}
