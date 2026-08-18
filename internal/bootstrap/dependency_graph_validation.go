package bootstrap

import (
	"fmt"

	"github.com/envpilot/contracts/domain"
)

// ValidateDependencyGraph is deliberately fail-closed. Agent-produced
// validation is authoritative; an absent validation block is not treated as
// success for a compiled template.
func ValidateDependencyGraph(graph domain.ServiceGraph) error {
	if graph.Validation == nil {
		return fmt.Errorf("dependency graph validation is missing")
	}
	if graph.Validation.Valid {
		return nil
	}
	if len(graph.Validation.Errors) == 0 {
		return fmt.Errorf("dependency graph validation failed")
	}
	issue := graph.Validation.Errors[0]
	if issue.Path != "" {
		return fmt.Errorf("dependency graph validation failed: %s at %s: %s", issue.Code, issue.Path, issue.Message)
	}
	return fmt.Errorf("dependency graph validation failed: %s: %s", issue.Code, issue.Message)
}

// ValidateDependencyGraphWithSelections permits only explicit non-default
// strategies to resolve the fail-closed Secret/PVC policy gate. It never
// materializes either resource kind.
func ValidateDependencyGraphWithSelections(graph domain.ServiceGraph, selections map[string]ResourceSelection) error {
	if graph.Validation == nil { return fmt.Errorf("dependency graph validation is missing") }
	for _, issue := range graph.Validation.Errors {
		if issue.Code != "strategy_required" { return fmt.Errorf("dependency graph validation failed: %s: %s", issue.Code, issue.Message) }
		selection, ok := selections[issue.ResourceID]
		if !ok || !selection.Include || selection.Strategy == "" || selection.Strategy == "ignore" { return fmt.Errorf("dependency graph validation failed: %s: %s", issue.Code, issue.Message) }
	}
	return nil
}
