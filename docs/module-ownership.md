# Module ownership

`bootstrap` is a reusable library. Its public package exposes deterministic
manifest generation, resource-policy validation, and cleanup safety primitives.
Session persistence and service orchestration remain internal implementation
details and are not imported by other modules.
