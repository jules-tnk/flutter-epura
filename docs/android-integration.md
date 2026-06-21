# Android Integration

Epura uses Android APIs conservatively. The app should keep permissions obvious,
avoid broad special access, and prefer Android system pickers or media APIs
over private filesystem assumptions.

## Android Boundaries

Diagram: [diagrams/android-boundaries.mmd](diagrams/android-boundaries.mmd)

Use this boundary map when a feature needs native Android behavior. The diagram
separates what Flutter owns, what the plugin layer owns, what the Kotlin bridge
owns, and what Android system UI must own.

## Permissions

Current manifest permissions:

- `READ_EXTERNAL_STORAGE` with `maxSdkVersion="32"` for legacy storage access.
- `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` for media review.
- `POST_NOTIFICATIONS` for reminders.
- `RECEIVE_BOOT_COMPLETED` to restore scheduled reminders after reboot.
- `SCHEDULE_EXACT_ALARM` for reminder timing where supported.
- `VIBRATE` for notification feedback.

The app does not request `INTERNET`, `MANAGE_EXTERNAL_STORAGE`,
`QUERY_ALL_PACKAGES`, usage access, accessibility services, VPN service,
contacts, calendar, or notification listener access.

## Storage Access Framework

The Kotlin bridge in `MainActivity` handles:

- folder picking through `ACTION_OPEN_DOCUMENT_TREE`;
- document picking through `ACTION_OPEN_DOCUMENT`;
- recursive folder listing with `DocumentsContract`;
- persistable read/write URI grants where supported;
- document deletion through `DocumentsContract.deleteDocument`;
- releasing persisted URI permissions.

SAF behavior is provider-dependent. Documentation and UI copy should avoid
promising that every selected file can be deleted or recovered.

## Media Library

Media items are loaded through `photo_manager` and represented as review items.
For media deletion, Epura first attempts Android trash through `moveToTrash`
where available and falls back to delete requests. The summary screen reports
trashed, permanently deleted, and failed items separately.

Do not replace this with silent file deletion. The system media layer exists so
Android can keep the user in control.

## Android Settings

`AndroidSettingsService` opens Android storage settings through the native
settings channel. This keeps Epura honest about storage it cannot inspect or
clean, such as app caches, hidden app data, and system storage.

## Integration Rules

- Prefer system pickers over broad filesystem permissions.
- Keep Android-only capabilities behind Dart service interfaces.
- Treat permission explanation as UX, not only implementation detail.
- Do not add special permissions just to make a shortcut more convenient.
- Validate storage, deletion, and permission changes on a real Android device
  before moving to the next milestone.
