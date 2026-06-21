# Features

Epura's feature set should stay organized around one product promise: the app
helps people make confident local cleanup decisions, but it does not decide for
them or operate like a generic phone cleaner.

## Feature Map

Diagram: [diagrams/feature-map.mmd](diagrams/feature-map.mmd)

Use this map when adding or removing user-visible surfaces. A new feature should
fit one of the existing capability groups before it earns a new top-level place
in the app. This keeps the home screen focused and protects the local-first,
no-account philosophy from slow scope creep.

## Review Flow

Diagram: [diagrams/review-flow.mmd](diagrams/review-flow.mmd)

The review flow is the core interaction contract. Mode selection, lookback
choice, scanning, review, confirmation, deletion, and summary should remain a
single understandable path even as new review modes are added.

The important maintenance rule is that grouping features are still review
features. Exact duplicates and bursts may organize candidates, but they must
not bypass review or final confirmation.

## Deletion Safety

Diagram: [diagrams/deletion-safety-flow.mmd](diagrams/deletion-safety-flow.mmd)

Deletion is the highest-trust part of Epura. The diagram records the safety
boundary between pending delete decisions, confirmed execution, Android trash
where available, permanent SAF deletion, and failure reporting.

Any future bulk action, group action, or shortcut must reuse this safety model:
collect decisions first, ask for explicit confirmation, then report what
happened.

## Current Capability Notes

- The default review path remains "Start Review" with a lookback picker.
- Quick modes expose high-value local workflows: recent files, largest files,
  screenshots, and large videos.
- Additional modes are available through the mode sheet: downloads, selected
  folders, per-folder reviews, duplicates, bursts, and skipped items.
- Downloads are manual imports because Android does not grant reusable broad
  Downloads access on modern devices.
- Storage insight is educational and bounded. It should not claim to inspect
  app cache, installed apps, cloud state, system storage, or hidden data.

## Feature Acceptance Rules

Before adding a feature, confirm that it:

- Works offline for the core use case.
- Requires no account.
- Sends no user files or behavior data away from the device.
- Preserves final deletion confirmation.
- Avoids broad or surprising Android permissions.
- Improves the review loop without making the app feel like a file manager.
