# Architecture

Epura is a Flutter app with thin native Android bridges only where Android
storage APIs require them. The architecture should keep product behavior in
Dart and isolate platform-specific work behind service interfaces.

## Overview

Diagram: [diagrams/architecture-overview.mmd](diagrams/architecture-overview.mmd)

This diagram is the starting point for understanding runtime ownership. UI
screens should depend on providers and services, not on raw platform channels or
database internals. Native Android code should remain an integration boundary,
not a second product layer.

## Components

Diagram: [diagrams/component-map.mmd](diagrams/component-map.mmd)

Use the component map to decide where a change belongs. The main rule is to keep
state transitions in providers, persistence in services, and presentation in
screens/widgets. Generated files should stay generated, and manual changes
should happen in their source files.

## Boundary Rules

- `EpuraApp` owns route registration, theme selection, and localization wiring.
- Screens assemble user flows and delegate state changes to providers.
- `FileService` owns scanning, imported documents, candidate grouping, and
  review-mode filtering.
- `ReviewProvider` owns the active review queue, decisions, deletion execution,
  session completion, and decision-memory persistence.
- `SettingsProvider` owns preferences, custom folder profiles, reminder choices,
  locale, theme, and review-prompt state.
- `StatsProvider` reads session history and derived statistics from
  `DatabaseService`.
- `DatabaseService` is the repository boundary over Drift. UI code should not
  query Drift tables directly.
- Kotlin `MainActivity` exposes Android-only document and settings actions over
  method channels.

## Change Guidance

When a new feature spans multiple layers, start with the user flow and keep the
cross-layer contract narrow. For example, a new Android storage capability
should usually appear as a method on an abstract Dart service, with the
MethodChannel implementation hidden behind that service.

Avoid adding a new global state holder unless a provider boundary is already too
broad for the behavior being introduced.
