# Data And Persistence

Epura stores app state locally. Persistence exists to make review sessions,
settings, folders, decision memory, and grouping faster or safer; it is not
analytics and should not become telemetry.

## Local Data Flow

Diagram: [diagrams/local-data-flow.mmd](diagrams/local-data-flow.mmd)

This diagram shows which runtime data is durable and which data is transient.
Use it when deciding whether a new field belongs in Drift, `SharedPreferences`,
an in-memory provider, or a disposable cache.

## Drift Schema

Diagram: [diagrams/persistence-er-model.mmd](diagrams/persistence-er-model.mmd)

The ER model reflects the current Drift tables in `EpuraDatabase`. Update the
diagram whenever a table, index, migration, or table purpose changes. Keep the
Markdown context focused on why the data exists; the table details belong in
the diagram and Drift source.

Current schema version: `6`.

Relationships shown through `fileKey` are logical matches used by services, not
database-enforced foreign keys.

Current durable tables:

- `review_sessions`: completed review-session summaries used for stats.
- `review_decisions`: local decision memory for skipped and never-ask-again
  files.
- `file_index`: advisory scan index for selected folders and media candidates.
- `dismissed_review_groups`: local memory for ignored duplicate or burst
  groups.

## Shared Preferences

`SharedPreferences` stores settings and small user choices:

- reminder time, cadence, and notification state;
- media scan toggles;
- custom folder profiles and last-reviewed timestamps;
- last review timestamp;
- locale and theme mode;
- accepted terms state;
- imported document records;
- cached scan summary counts and size;
- Play Store review-prompt state.

Do not use preferences for growing datasets. If a value can grow with files,
sessions, or groups, prefer Drift.

## Local Data Rules

- Keep all core app data on-device.
- Do not add analytics-style event tables.
- Prefer stable file keys over raw file paths when long-term identity is
  needed.
- Keep file indexes advisory. A failed index write must not block review.
- Treat thumbnails and scan progress as cache or transient UI state.
- Clearing Epura history must not delete user files or revoke folder grants
  unless the UI explicitly says so.

## Migration Guidance

Drift schema changes require:

- table/source updates in `lib/services/epura_database.dart`;
- regenerated `epura_database.g.dart`;
- a schema-version bump and migration path;
- focused tests for existing data compatibility where behavior is affected;
- updates to [diagrams/persistence-er-model.mmd](diagrams/persistence-er-model.mmd).
