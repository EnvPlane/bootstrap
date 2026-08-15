// Package bootstrap exposes deterministic manifest generation and cleanup
// safety primitives for bootstrap orchestration consumers.
package bootstrap

import (
	"github.com/envpilot/bootstrap/internal/bootstrap"
	"github.com/envpilot/contracts/domain"
)

type CleanupSafetyConfig = bootstrap.CleanupSafetyConfig
type ManagedResourceRuntime = bootstrap.ManagedResourceRuntime
type ManifestTemplate = bootstrap.ManifestTemplate
type ManifestTemplateGeneratorOptions = bootstrap.ManifestTemplateGeneratorOptions
type NetworkPolicyConfig = bootstrap.NetworkPolicyConfig
type ResourcePolicyConfig = bootstrap.ResourcePolicyConfig
type ResourceSelection = bootstrap.ResourceSelection
type ManifestTemplateValidationIssue = bootstrap.ManifestTemplateValidationIssue
type ManifestTemplateValidationResult = bootstrap.ManifestTemplateValidationResult

func NewManagedResourceRuntime(initial []domain.ResourceSnapshot, config CleanupSafetyConfig, projectID, environmentID string) *ManagedResourceRuntime {
	return bootstrap.NewManagedResourceRuntime(initial, config, projectID, environmentID)
}

func GenerateManifestTemplates(snapshots []domain.ResourceSnapshot, selections map[string]ResourceSelection, options ManifestTemplateGeneratorOptions) ([]ManifestTemplate, error) {
	return bootstrap.GenerateManifestTemplates(snapshots, selections, options)
}

func GenerateResourcePolicyTemplates(policy ResourcePolicyConfig, featureNamespace string, labels, annotations map[string]string) ([]ManifestTemplate, error) {
	return bootstrap.GenerateResourcePolicyTemplates(policy, featureNamespace, labels, annotations)
}

func GenerateNetworkPolicyTemplates(config NetworkPolicyConfig, featureNamespace string, labels, annotations map[string]string) ([]ManifestTemplate, error) {
	return bootstrap.GenerateNetworkPolicyTemplates(config, featureNamespace, labels, annotations)
}

func ValidateResourcePolicyConfig(policy ResourcePolicyConfig) error {
	return bootstrap.ValidateResourcePolicyConfig(policy)
}

func ValidateNetworkPolicyConfig(config NetworkPolicyConfig) error {
	return bootstrap.ValidateNetworkPolicyConfig(config)
}

func MarshalDeterministicYAML(value any) string { return bootstrap.MarshalDeterministicYAML(value) }
func ResourceSnapshotKey(snapshot domain.ResourceSnapshot) string {
	return bootstrap.ResourceSnapshotKey(snapshot)
}

func ValidateManifestTemplates(templates []ManifestTemplate) ManifestTemplateValidationResult {
	return bootstrap.ValidateManifestTemplates(templates)
}
func DefaultCleanupSafetyConfig() CleanupSafetyConfig { return bootstrap.DefaultCleanupSafetyConfig() }
func ValidateCleanupSafetyConfig(config CleanupSafetyConfig, targetNamespaces []string) error {
	return bootstrap.ValidateCleanupSafetyConfig(config, targetNamespaces)
}
func FilterCleanupEligibleResources(resources []domain.ResourceSnapshot, config CleanupSafetyConfig) []domain.ResourceSnapshot {
	return bootstrap.FilterCleanupEligibleResources(resources, config)
}
func FilterCleanupEligibleResourcesForEnvironment(resources []domain.ResourceSnapshot, config CleanupSafetyConfig, projectID, environmentID string) []domain.ResourceSnapshot {
	return bootstrap.FilterCleanupEligibleResourcesForEnvironment(resources, config, projectID, environmentID)
}
func IsEnvPlaneManaged(resource domain.ResourceSnapshot, projectID, environmentID string) bool {
	return bootstrap.IsEnvPlaneManaged(resource, projectID, environmentID)
}
func ValidateDeleteManagedResource(resource domain.ResourceSnapshot, config CleanupSafetyConfig, projectID, environmentID string) error {
	return bootstrap.ValidateDeleteManagedResource(resource, config, projectID, environmentID)
}
