# Manual Full environment must preserve the source image tag

## Observed

When a Full environment is created manually before SCM supplies a commit SHA,
the generated Deployment rendered `image: registry.example/app:`. Kubernetes
rejected the reference with `InvalidImageName`.

## Expected

Use the commit SHA for webhook-driven environments. For a manual environment
without one, preserve the scanned image tag until an explicit feature artifact
is selected.

## Resolution

Generate a conditional template that falls back to the source image tag when
`CommitSHA` is empty, and cover it with a generator test.
