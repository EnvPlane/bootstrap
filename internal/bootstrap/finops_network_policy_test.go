package bootstrap

import (
	"strings"
	"testing"
)

func TestFeatureAllowPoliciesExcludeSeparatePVCExporter(t *testing.T) {
	for _, mode := range []string{"restricted", "allow all"} {
		items, err := GenerateNetworkPolicyTemplates(NetworkPolicyConfig{
			BaseToFeature: true, FeatureToBase: true, AllowBaseNamespacePolicies: true,
			BaseNamespaces: []string{"base"}, EgressMode: mode,
		}, "feature", nil, nil)
		if err != nil {
			t.Fatal(err)
		}
		for _, item := range items {
			if !strings.Contains(item.YAML, "envplane.io/pvc-exporter") || !strings.Contains(item.YAML, "DoesNotExist") {
				t.Fatalf("%s allows traffic to isolated exporter: %s", item.Name, item.YAML)
			}
		}
	}
	items, err := GenerateNetworkPolicyTemplates(NetworkPolicyConfig{EgressMode: "deny all"}, "feature", nil, nil)
	if err != nil || len(items) != 1 {
		t.Fatalf("deny all changed: %v", err)
	}
	if strings.Contains(items[0].YAML, "envplane.io/pvc-exporter") {
		t.Fatal("deny-all must stay namespace-wide")
	}
}
