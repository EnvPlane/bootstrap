package bootstrap

import (
	"os"
	"strings"
	"testing"
)

func TestLocalDevEnvironmentContract(t *testing.T) {
	makefile, err := os.ReadFile("../../Makefile")
	if err != nil {
		t.Fatalf("read Makefile: %v", err)
	}
	if !strings.Contains(string(makefile), "test:") || strings.Contains(string(makefile), "docker compose up --build") {
		t.Fatal("Makefile must expose reproducible test targets without the removed compose harness")
	}
}
