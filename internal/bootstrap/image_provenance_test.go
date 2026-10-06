package bootstrap

import (
	"testing"
)

func TestUnchangedImageRetainsExactScannedReference(t *testing.T) {
	for _, image := range []string{"registry.gitlab.com/envplane/frontend@sha256:1234", "localhost:5000/app:v2", "mysql:8.4", "example/app"} {
		container := map[string]any{"name": "app", "image": image}
		spec := map[string]any{"containers": []any{container}}
		rewriteContainerImageSlice(spec, "containers", "{{ .CommitSHA }}", "")
		want := "{{ if .CommitSHA }}" + imageRepository(image) + ":{{ .CommitSHA }}{{ else }}" + image + "{{ end }}"
		if container["image"] != want {
			t.Fatalf("image %q lost provenance: %v", image, container["image"])
		}
	}
}
