package bootstrap

import (
	"strings"
	"testing"
)

func TestPublicManifestSurfaceIsDeterministic(t *testing.T) {
	first := MarshalDeterministicYAML(map[string]any{"b": "two", "a": "one"})
	second := MarshalDeterministicYAML(map[string]any{"a": "one", "b": "two"})
	if first != second || !strings.Contains(first, "a: one") || !strings.Contains(first, "b: two") {
		t.Fatalf("public manifest output is not deterministic: %q / %q", first, second)
	}
}
