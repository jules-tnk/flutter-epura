# Epura Documentation

This directory documents the current app shape without turning the repository
into a large product handbook. The root [README](../README.md) remains the
canonical public and engineering entry point.

## Reference Pages

- [features.md](features.md): user-facing capabilities, review boundaries, and
  maintenance notes for feature flows.
- [architecture.md](architecture.md): Flutter, provider, service, and Android
  channel boundaries.
- [data-and-persistence.md](data-and-persistence.md): local Drift schema,
  settings storage, and cache rules.
- [android-integration.md](android-integration.md): Android permissions,
  Storage Access Framework, media library deletion, and settings intents.

## Diagram Sources

Mermaid files under [diagrams](diagrams) are the canonical diagram sources.
Markdown pages should link to these files and explain the decisions, tradeoffs,
or maintenance rules around them. Do not duplicate every node and edge in prose.

- [diagrams/feature-map.mmd](diagrams/feature-map.mmd)
- [diagrams/review-flow.mmd](diagrams/review-flow.mmd)
- [diagrams/deletion-safety-flow.mmd](diagrams/deletion-safety-flow.mmd)
- [diagrams/architecture-overview.mmd](diagrams/architecture-overview.mmd)
- [diagrams/component-map.mmd](diagrams/component-map.mmd)
- [diagrams/local-data-flow.mmd](diagrams/local-data-flow.mmd)
- [diagrams/persistence-er-model.mmd](diagrams/persistence-er-model.mmd)
- [diagrams/android-boundaries.mmd](diagrams/android-boundaries.mmd)
- [diagrams/tech-stack.mmd](diagrams/tech-stack.mmd)
- [diagrams/release-validation-flow.mmd](diagrams/release-validation-flow.mmd)

## Local Planning Artifacts

`docs/superpowers/` is reserved for local agent plans and specs. It is ignored
by git and should not be linked from tracked documentation.
