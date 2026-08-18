package bootstrap

import (
	"testing"
	"time"

	"github.com/envpilot/contracts/domain"
)

func TestStatefulCleanupNeverDeletesSourcePVCOrDatabase(t *testing.T) {
	plan, err := domain.CompileStatefulExecutionPlan("tenant-a", "project-a", "env-a", "rev-1", "sha256:revision", "feature-a", []domain.StatefulDependencyPolicy{{ID: "db", Kind: "PersistentVolumeClaim", Strategy: domain.StatefulStrategyVolumeSnapshot, SourceNamespace: "base", SourceName: "data", TargetNamespace: "feature-a", TargetName: "data", StorageClass: "fast", SnapshotClass: "snap", Size: "1Gi", AccessModes: []string{"ReadWriteOnce"}, CSIProvisioner: "csi"}}, "sha256:input", time.Now())
	if err != nil {
		t.Fatal(err)
	}
	if ShouldDeleteStatefulResource(plan, domain.ResourceSnapshot{Kind: "PersistentVolumeClaim", Namespace: "base", Name: "data"}) {
		t.Fatal("source PVC was cleanup eligible")
	}
	if !ShouldDeleteStatefulResource(plan, domain.ResourceSnapshot{Kind: "PersistentVolumeClaim", Namespace: "feature-a", Name: "data"}) {
		t.Fatal("feature PVC was not cleanup eligible")
	}
}
