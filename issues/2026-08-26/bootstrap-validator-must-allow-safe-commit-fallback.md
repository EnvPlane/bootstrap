# Bootstrap validator must allow safe commit fallback

## Observed

The manifest generator renders a safe `if .CommitSHA` fallback so manual Full
environments retain their scanned image tag. Bootstrap compilation rejected the
template because its validator accepted only standalone variable expressions.

## Expected

The validator accepts balanced `if`, `else`, and `end` blocks that reference an
allowlisted EnvPlane variable, while still rejecting arbitrary template logic.

## Resolution

Allow the constrained control expressions and cover the image-tag fallback
template with a validation test.
