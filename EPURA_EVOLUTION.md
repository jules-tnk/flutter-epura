# Epura Evolution

Date: 2026-05-27

## Purpose

Epura has reached its first important milestone: it works, it is on Google
Play, and it already has a clear identity. It helps people review files before
they become clutter. It does this locally, without accounts, without tracking,
and without pretending that a third-party app can magically clean the whole
phone.

This document defines the direction Epura should take next. The goal is not to
turn Epura into a generic "phone booster" or aggressive cleaner. The goal is to
make Epura the most trustworthy, simple, useful offline storage review app for
Android.

## Executive Direction

Epura should evolve from:

> "A swipe review app for recent photos, videos, folders, and imported
> downloads"

into:

> "A private, offline phone cleanup assistant that helps users make safe,
> confident keep/delete decisions in small sessions."

The app should expand by adding smarter local review modes, safer deletion,
better explanations, and more useful storage insight. It should not expand by
adding accounts, cloud backup, analytics, advertising, broad background
surveillance, or vague automated cleanup claims.

The strongest product position is:

> Epura asks before it deletes.

That sentence should remain the center of the product. It is simple,
understandable, and meaningfully different from many cleaner apps that users
distrust.

## Current App Baseline

The current codebase and public copy show that Epura already has a coherent
foundation.

Existing user-facing features:

- Swipe review: keep, delete, or skip.
- End-of-session confirmation before actual deletion.
- Media scanning: photos and videos.
- Custom folder scanning through Android system folder grants.
- Manual downloaded-file import through the Android system picker.
- Lookback picker before review.
- Daily or weekly reminders.
- Local stats, session history, storage freed, and streaks.
- English and French localization.
- Light, dark, and system theme modes.
- In-app privacy policy and terms.
- Public web landing page and Google Play badge.

Existing technical foundation:

- Flutter app using Provider.
- Local SQLite through `sqflite` for review session history.
- Local `SharedPreferences` for settings.
- `photo_manager` for media access.
- Android Storage Access Framework for user-selected folders and documents.
- Local notifications through `flutter_local_notifications`.
- No account system.
- No analytics code visible in the current app audit.
- No internet permission in `android/app/src/main/AndroidManifest.xml`.

Existing promise:

- No data leaves the device.
- No analytics.
- No tracking.
- No accounts.
- Files are deleted only when the user explicitly chooses deletion.

These promises are not marketing decoration. They are product constraints.

## Non-Negotiable Product Philosophy

Every future feature must pass these rules.

### 1. Local First

The feature must work without an internet connection. If a feature cannot work
offline, it does not belong in Epura unless it is clearly outside the core app
and user-triggered, such as opening the Google Play listing.

### 2. No Account

Epura must not require sign-up, login, sync identity, cloud identity, or any
third-party account. Account systems would create privacy cost, support cost,
security cost, and conceptual complexity.

### 3. No Data Collection

No analytics SDK, ad SDK, crash reporting SDK, attribution SDK, remote config
SDK, or behavioral telemetry should be added by default. If the app later needs
diagnostic help, use explicit user-controlled export: "copy diagnostic report"
or "send email with attached report", with the content visible before sending.

### 4. User Decides

Epura may recommend, group, sort, warn, and explain. It should not silently
delete. Any bulk action must keep a review or confirmation step.

### 5. Permission Minimalism

Ask only for permissions tied to obvious value. Android and Play policy both
push developers to minimize sensitive access. Users also interpret extra
permissions as trust risk.

### 6. Small Sessions

Epura should not demand that users "clean their phone" in one long task. It
should make useful progress possible in 30 seconds, 2 minutes, or 5 minutes.

### 7. Existing Features Stay

The current review flow, media scanning, folder scanning, downloads import,
reminders, stats, localization, and legal/privacy surfaces should be improved,
not replaced.

## Product North Star

Primary north star:

> Weekly active users complete at least one safe local review session and feel
> that Epura helped them free or understand storage without risk.

Because Epura intentionally avoids analytics, measure this mainly through:

- Play Console retention and uninstall metrics.
- Play Console ratings and review themes.
- User emails or GitHub issues.
- Voluntary tester feedback.
- Manual dogfooding with large real galleries.
- Local-only in-app achievements or stats visible only to the user.

The north star should not be "more files deleted". Deleting more is not always
good. The better target is confident cleanup.

## Research Summary

The external research shows four strong signals.

### Signal 1: The pain is real, but users often tolerate it

Reddit posts repeatedly describe galleries full of screenshots, memes, random
videos, duplicate media, WhatsApp forwards, and "I'll delete this later" files.
Pixel and Google Photos threads also show that users are confused by storage
breakdowns, cloud/device distinctions, and large videos.

Implication for Epura:

- Expand around the exact clutter people recognize: screenshots, large videos,
  duplicate/similar photos, downloads, and selected app folders.
- Explain device storage versus cloud storage plainly.
- Do not promise that Epura can explain all "Other" or hidden system storage.

### Signal 2: Users distrust cleaner apps

Reddit discussions contain strong distrust of cleaner apps with popups, ads,
  unsafe claims, excessive permissions, subscriptions, and broad control over
  the phone. This distrust is a strategic opening for Epura.

Implication for Epura:

- Lead with "No account. No analytics. No ads. Works offline."
- Keep the app visibly calm and honest.
- Avoid terms like "boost", "virus", "AI cleaner", "magic clean", "deep clean",
  or "one tap optimize" unless they are technically true.
- Treat the absence of internet permission as a feature.

### Signal 3: The market already validates swipe cleanup

Multiple recent apps and Reddit posts use the same pattern: swipe right to keep,
swipe left to delete, review before deleting, and organize obvious gallery
clutter. This confirms that Epura's current interaction model is not a dead
end. It is a proven pattern.

Implication for Epura:

- Keep swipe review as the core.
- Differentiate through trust, safety, clarity, local operation, and broad but
  bounded file support rather than through louder claims.

### Signal 4: Android storage constraints shape the roadmap

Android's storage model is intentionally restrictive. Apps can access selected
documents and folders through the Storage Access Framework, but Android 11+
blocks broad tree access to directories such as Downloads. Media deletion on
modern Android often requires user confirmation unless the app has special
media-management status. Google Play also restricts broad all-files access.

Implication for Epura:

- Keep using user-selected SAF access.
- Do not chase `MANAGE_EXTERNAL_STORAGE` unless Epura becomes a true file
  manager, which it should not.
- Improve Downloads through manual import and clearer flows rather than trying
  to bypass Android restrictions.
- Make permission behavior part of the UX, not an implementation footnote.

## Target Users

### 1. The Camera Roll Accumulator

This user takes many photos and videos, saves memes, screenshots receipts, and
rarely cleans up. They do not want a file manager. They want a quick review.

Best Epura value:

- Screenshot mode.
- Large video mode.
- Similar-photo groups.
- Quick daily/weekly review.

### 2. The Low Storage User

This user hits "storage almost full" at bad moments. They need fast relief but
also fear deleting something important.

Best Epura value:

- "Free space fast" mode sorted by largest safe review items.
- Clear size estimates before review.
- Existing final deletion confirmation, with future undo/recovery clarity.
- Honest "what Epura can and cannot clean" guidance.

### 3. The Privacy-Conscious User

This user avoids cloud cleaners, ads, analytics, and account systems. They may
inspect permissions and privacy labels.

Best Epura value:

- No internet permission.
- No account.
- No analytics.
- Local privacy receipt.
- Optional open-source build/reproducibility story if the project later goes
  public.

### 4. The Non-Technical User

This user wants less clutter but does not understand Android storage scopes,
permissions, or media libraries.

Best Epura value:

- Very short explanations.
- "Why am I seeing this permission?" screens.
- Review modes named by real-world intent.
- No scary or technical cleanup claims.

### 5. The Organized Power User

This user wants filters, history, custom folders, and repeated workflows, but
still values privacy.

Best Epura value:

- Custom folder review profiles.
- Advanced filters hidden behind simple entry points.
- Local search and decision history.
- Exportable local backup of Epura settings and stats.

## The Core Product Loop

Future Epura should organize around this loop:

1. Show the user what can be reviewed now.
2. Let the user choose a small review mode.
3. Present items in a calm keep/delete/skip flow.
4. Preserve the existing end-of-session confirmation before deletion.
5. Show exactly what changed.
6. Remind later based on the user's chosen cadence.
7. Make the next session easier than the last one.

This loop preserves the existing app while making it more valuable.

## Roadmap Overview

Recommended sequence:

1. Safety and trust upgrade.
2. Review modes and filtering.
3. Local intelligence for duplicates and screenshots.
4. Storage insight and education.
5. Growth surfaces and feedback loop.
6. Optional advanced local tools.

The order matters. Safety and trust should come before more aggressive
recommendations.

## Phase 1: Safety And Trust Upgrade

### Existing Behavior To Preserve: Final Deletion Confirmation

Epura already asks for confirmation at the end of each review session before
performing actual deletion. That behavior is part of the product's trust model
and should be treated as an invariant, not a future roadmap item.

Preservation criteria:

- Do not remove the final confirmation step.
- Do not replace it with silent background deletion.
- Keep deletion copy explicit about permanence and recoverability.
- Any future bulk-delete or duplicate-cleanup workflow must reuse the same
  confirmation principle.

### Feature 1.1: Undo Window After Completion

Description:

After completing a session, give the user a short local undo opportunity before
executing permanent deletion for SAF documents. For media files, prefer Android
trash APIs where available, because trash can be safer than immediate
permanent deletion.

Philosophy fit:

- Strong. Safety is a trust feature.

Feasibility:

- Medium.
- Android media files can use system trash flows on Android 11+.
- SAF document deletion through `DocumentsContract.deleteDocument()` may be
  permanent and provider-dependent, so Epura must not promise universal
  recovery.

Implementation notes:

- Separate "pending deletion", "moved to trash", and "permanently deleted"
  wording.
- For SAF/imported documents, show a stronger confirmation.
- For media, investigate replacing direct media deletion with trash/delete
  request flows where possible.

Risks:

- Different Android gallery providers behave differently.
- If recovery depends on the device gallery app, Epura must say so.

Priority:

- Must have, but can be split into clearer recovery copy first and system
  trash/undo behavior later.

### Feature 1.2: Permission Explanation Center

Description:

Add a small "What Epura can access" screen under Settings or Help. It explains:

- Photos/videos permission: used to show media for review.
- Folder grants: only folders the user explicitly selected.
- Download import: only files the user manually picked.
- Notifications: only for reminders.
- No internet permission: files do not leave the phone.

Philosophy fit:

- Very strong. Trust is part of the app's utility.

Feasibility:

- High.
- UI and localization only.

Implementation notes:

- Use current manifest and settings state to show actual access.
- Show selected folders with revoke buttons.
- Add "No internet permission" if still true in the manifest.

Risks:

- Copy must stay accurate as permissions change.

Priority:

- Must have.

### Feature 1.3: Local Privacy Receipt

Description:

After first launch or from Settings, show a concise privacy receipt:

- Data stored locally: settings, review history, selected folder grants.
- Data not collected: photos, videos, files, identifiers, analytics.
- Network use: none by the app core.
- User controls: revoke folders, clear imported files, clear local history.

Philosophy fit:

- Very strong.

Feasibility:

- High.
- Requires a local "clear Epura history" action if not already present.

Implementation notes:

- Add a "Delete Epura history" action for review sessions and local stats.
- Keep it distinct from deleting user files.

Risks:

- Data safety and privacy policy must stay consistent.

Priority:

- High.

## Phase 2: Review Modes And Filtering

### Feature 2.1: Review Modes On Home Screen

Description:

Replace the single "Start Review" mental model with simple review modes:

- Recent files.
- Screenshots.
- Large videos.
- Downloads.
- Selected folders.
- Everything since last review.

The current "Start Review" should remain as the default path. Review modes
should feel like shortcuts, not a new complex dashboard.

Philosophy fit:

- Strong. The app becomes more useful while staying easy.

Feasibility:

- High for mode UI and simple filters.
- Medium for screenshot classification depending on Android media metadata.

Implementation notes:

- Keep one primary button: "Start Review".
- Add a compact row/list of modes below the summary card.
- Each mode opens the existing lookback picker or applies a sensible default.
- Store the last used mode locally.

Risks:

- Too many modes can clutter the first screen.
- Start with 3 modes: Recent, Screenshots, Large videos.

Priority:

- Must have.

### Feature 2.2: Largest First Review

Description:

Let users review the files that can free the most storage first. This should be
especially useful for videos.

Philosophy fit:

- Strong. It helps users solve storage pressure quickly without automation.

Feasibility:

- High.
- Current `ReviewItem` already has `size`.

Implementation notes:

- Add sorting options: newest first, largest first, oldest first.
- Keep the default as current behavior unless the user chooses otherwise.
- In summary, show "Largest item" and "Top 10 could free X".

Risks:

- Users may over-delete large but valuable videos. Mitigate with preview and
  confirmation.

Priority:

- Must have.

### Feature 2.3: Screenshot Review

Description:

Add a mode that finds screenshots and presents them in review. Screenshots have
clear clutter patterns: receipts, confirmation pages, memes, chats, tickets,
temporary reference material.

Philosophy fit:

- Very strong. It is local, concrete, and high-frequency.

Feasibility:

- Medium-high.
- Likely classification inputs:
  - Media path or album name contains screenshot/screen shot equivalents.
  - File name patterns from OEM screenshot tools.
  - Image dimensions matching screen aspect ratios.
  - MediaStore relative path if available through the plugin or a native query.

Implementation notes:

- Start with conservative detection.
- Put uncertain items in normal review, not screenshot mode.
- Avoid OCR in the first version.

Risks:

- OEM naming differences.
- False negatives are acceptable; false positives should be minimized.

Priority:

- Must have.

### Feature 2.4: Downloads Inbox

Description:

Improve the current manual "Add downloaded files" flow into a clearer Downloads
Inbox:

- Home card shows imported download count and total size.
- User can add files, review imports, clear imports, or review imported files
  only.
- Explain why Android requires manual selection for Downloads.

Philosophy fit:

- Strong. It works with Android's privacy model rather than bypassing it.

Feasibility:

- High.
- Current imported-document persistence already exists.

Implementation notes:

- Rename "Add downloaded files" to "Import downloads".
- Add "Review downloads" mode when imports exist.
- Add file type filters for PDF, archives, APK, audio, documents.

Risks:

- Users may expect automatic Downloads scanning. Explain clearly and briefly.

Priority:

- High.

### Feature 2.5: Custom Folder Profiles

Description:

Let users name selected folders and review them as separate profiles:

- Receipts.
- WhatsApp media export.
- Camera imports.
- Work files.
- Temporary downloads.

Philosophy fit:

- Strong if kept simple.

Feasibility:

- Medium.
- Current `ScanFolderGrant` stores URI and name. Additional metadata can be
  stored locally.

Implementation notes:

- Add optional local nickname.
- Add per-folder review shortcut.
- Add per-folder last reviewed date.
- Keep recursive scan but show folder-specific progress.

Risks:

- Can drift toward file-manager complexity. Keep it review-oriented.

Priority:

- High.

## Phase 3: Local Intelligence

### Feature 3.1: Exact Duplicate Detection

Description:

Identify likely exact duplicates before introducing fuzzy or AI-like similarity.
Group files that are very likely the same, and let users choose what to keep.

Possible signals:

- Same size.
- Same dimensions or duration.
- Same filename after normalization.
- Same date or near date.
- Optional content hash for selected candidates.

Philosophy fit:

- Strong. Duplicate cleanup is a common user need and can be done locally.

Feasibility:

- Medium.
- Metadata-only duplicate detection is easy but can be wrong.
- Content hashing is more accurate but can be expensive for large videos.

Implementation notes:

- Start with photos and screenshots.
- Do exact duplicate candidates first.
- Never auto-delete a duplicate.
- Present groups as "These look identical" with a best-guess keep suggestion.

Risks:

- False positives destroy trust.
- Hashing too much media can drain battery or feel slow.

Priority:

- High, after safety work.

### Feature 3.2: Similar Photo Groups

Description:

Group visually similar images so the user can keep the best and delete the
rest. Use lightweight on-device perceptual hashing before considering ML.

Philosophy fit:

- Strong if framed as "looks similar", not "safe to delete".

Feasibility:

- Medium.
- Perceptual hashing is a known approach for near-duplicate image detection.
- It is more feasible than cloud AI and fits offline constraints.

Implementation notes:

- Generate thumbnail-sized hashes in a background isolate.
- Cache hashes in SQLite.
- Start with screenshots and photos, not videos.
- Use conservative thresholds.
- Show side-by-side comparison for each group.
- Store "do not group these again" local feedback.

Risks:

- Similar does not mean duplicate.
- Screenshots with similar layouts can be false positives.
- Needs careful UI to preserve user control.

Priority:

- High, but after exact duplicates.

### Feature 3.3: Burst And Best-Shot Review

Description:

Detect photos taken close together in time and let the user compare them as a
group. This is useful for repeated shots, kids/pets/action photos, and attempts
to capture one moment.

Philosophy fit:

- Strong. It helps users decide instead of deciding for them.

Feasibility:

- Medium.
- Time clustering is easy.
- "Best shot" detection is hard; avoid automatic quality claims at first.

Implementation notes:

- Group images taken within a small time window.
- Let user mark one or more keeps.
- Use zoom and full-screen compare.

Risks:

- Groups can include unrelated images taken close together.

Priority:

- Medium-high.

### Feature 3.4: Large Video Review

Description:

Make large videos a first-class cleanup surface. Users often underestimate how
large videos are, and Reddit storage threads repeatedly point to large videos
as a major cause.

Philosophy fit:

- Very strong.

Feasibility:

- High for sorting and reviewing by size.
- Medium for video playback preview depending on current preview capabilities.

Implementation notes:

- Add video duration and size prominently.
- Add "largest videos" review mode.
- Add thumbnail prefetch and full-screen preview.
- Consider external viewer fallback.

Risks:

- Deleting videos can be high regret. Use confirmation.

Priority:

- Must have.

### Feature 3.5: Blurry Or Low-Quality Photo Suggestions

Description:

Identify potentially blurry images and show them as a review mode.

Philosophy fit:

- Medium. Useful, but riskier because the app judges quality.

Feasibility:

- Medium-low for robust results.
- Simple local blur detection can work but may flag artistic or low-light
  photos.

Implementation notes:

- Defer until duplicate and screenshot modes are reliable.
- Call it "Possibly blurry" rather than "Bad photos".
- No auto-delete.

Risks:

- False positives can feel insulting or unsafe.

Priority:

- Later.

## Phase 4: Storage Insight And Education

### Feature 4.1: Local Storage Dashboard

Description:

Show a simple storage dashboard:

- Device free space.
- Photos selected for review.
- Videos selected for review.
- Imported downloads.
- Selected folders.
- Space freed over time.

Philosophy fit:

- Strong if scoped honestly.

Feasibility:

- Medium.
- Device free/total storage can be read locally.
- Epura can accurately show what it can access, not the whole hidden system.

Implementation notes:

- Use wording like "Epura can review" instead of "Your whole phone".
- Link to Android system storage settings for things Epura cannot manage.

Risks:

- Users may expect Files by Google-level whole-device classification.

Priority:

- High.

### Feature 4.2: "What Is Taking Space?" Guide

Description:

Add a local guide that explains common storage categories:

- Photos and videos.
- Downloads.
- App cache.
- Offline media from streaming apps.
- Cloud/device confusion.
- System and hidden app data.

The guide should include actions Epura can help with and actions that must be
done in Android settings or another app.

Philosophy fit:

- Strong. Helping users manage their phone does not always mean automating.

Feasibility:

- High.
- Content and localization only.

Implementation notes:

- Keep copy short.
- Add "Open Android storage settings" button.
- Do not claim Epura can clear app caches or hidden system files.

Risks:

- Too much help content can feel like documentation. Keep it contextual.

Priority:

- High.

### Feature 4.3: Cleanup Plan

Description:

Offer a simple local plan:

- "2 minutes: review screenshots."
- "5 minutes: review largest videos."
- "Weekly: review new files since last session."
- "Monthly: review downloads."

Philosophy fit:

- Strong. It helps users build a habit without gamification excess.

Feasibility:

- High.
- Based on local counts and sizes.

Implementation notes:

- Plan is computed locally.
- No behavioral tracking beyond local app state.
- Let users dismiss suggestions.

Risks:

- Could become naggy. Keep it optional and quiet.

Priority:

- Medium-high.

### Feature 4.4: App Cache And Unused Apps Guidance

Description:

Epura should not try to clear other apps' caches directly. Instead, it can
teach users how to use Android's built-in storage tools and optionally deep
link to system settings.

Philosophy fit:

- Medium-strong if honest.

Feasibility:

- Medium.
- Direct cache clearing is not generally available to normal apps.
- Usage/app inventory features may require sensitive access that does not fit
  Epura's minimal permission strategy.

Implementation notes:

- Add a guide: "For app cache, use Android Settings."
- Avoid `QUERY_ALL_PACKAGES` and usage-access flows unless there is a very
  strong future reason.

Risks:

- If overdone, Epura becomes a generic maintenance guide rather than a review
  app.

Priority:

- Later, mostly educational.

## Phase 5: Habit And Retention Without Tracking

### Feature 5.1: Smarter Local Reminders

Description:

Improve reminders so they feel helpful rather than generic.

Examples:

- "You have 18 new files to review."
- "Large videos are waiting."
- "Your weekly cleanup is ready."
- "No review needed today."

Philosophy fit:

- Strong if fully local and opt-in.

Feasibility:

- Medium.
- Requires background scan decisions and careful Android notification behavior.
- Android exact alarm restrictions mean Epura should evaluate whether exact
  reminders are truly needed.

Implementation notes:

- Prefer user-chosen cadence.
- Avoid asking for exact alarm special access unless the app genuinely needs
  exact timing.
- Consider inexact reminders if adequate.
- Keep notification content private and minimal.

Risks:

- Android OEM background behavior can be inconsistent.
- Notification permissions and exact alarm permissions add friction.

Priority:

- Medium-high.

### Feature 5.2: Review Streaks With Healthier Framing

Description:

Keep streaks, but frame them as consistency rather than pressure.

Examples:

- "3 reviews this month."
- "12 minutes spent cleaning."
- "2.4 GB reviewed."
- "You skipped 8 files for later."

Philosophy fit:

- Strong if calm.

Feasibility:

- High.
- Current stats already exist.

Implementation notes:

- Add monthly summary.
- Add local achievements only if they are not childish or manipulative.
- Avoid shame copy.

Risks:

- Over-gamification can conflict with utility.

Priority:

- Medium.

### Feature 5.3: "Later" Queue

Description:

Skipped files should become a visible "Later" queue instead of disappearing
into ambiguity.

Philosophy fit:

- Strong. It respects uncertainty.

Feasibility:

- Medium.
- Requires local per-file decision history.

Implementation notes:

- Store skipped file keys locally.
- Add "Review skipped files" mode.
- Let users set cooldown: tomorrow, next week, never ask again.

Risks:

- Stable file identity across MediaStore and SAF providers can be tricky.

Priority:

- High.

### Feature 5.4: Never Ask Again

Description:

When a user keeps a file, let them optionally mark it as "Do not show again" so
it does not reappear in long lookback reviews.

Philosophy fit:

- Strong. It reduces repeated work.

Feasibility:

- Medium.
- Requires local file identity and decision history.

Implementation notes:

- Use a composite key: source, media id or URI, size, modified timestamp.
- If identity is uncertain, fail open and show the file again rather than hide
  it incorrectly.

Risks:

- File identity changes after move/edit.

Priority:

- High.

## Phase 6: Growth And Popularity Without Betraying The App

Popularity should come from clarity, trust, and usefulness. Epura should not
grow by adding tracking or manipulative monetization.

### Growth 6.1: Store Listing Repositioning

Recommended short positioning:

> Review photos, videos, folders, and downloads before they become clutter.
> Offline, no account, no analytics.

Store listing should highlight:

- Swipe to keep or delete.
- Screenshots and large videos.
- Downloads and selected folders.
- Works offline.
- No account.
- No analytics.
- Asks before deleting.

Feasibility:

- High.
- No code changes.

Risks:

- Do not keyword-stuff. Google Play metadata policy requires clear, accurate,
  non-misleading descriptions.

Priority:

- Must have.

### Growth 6.2: Better Screenshots

The Play Store screenshots should tell the product story in order:

1. "Review clutter before it piles up."
2. "Swipe to keep or delete."
3. "Find screenshots and large videos."
4. "Import downloads and selected folders."
5. "No account. No analytics. Works offline."

Feasibility:

- High.

Risks:

- Screenshots must match the real app. Any discrepancy damages trust.

Priority:

- Must have.

### Growth 6.3: Localized Store Presence

Epura already supports English and French. The Google Play listing and
screenshots should be localized for both.

Feasibility:

- High.

Implementation notes:

- French screenshots should use the French app UI.
- French description should not be a literal low-quality translation.

Risks:

- Store assets must be kept in sync with app changes.

Priority:

- High.

### Growth 6.4: Review Prompt At The Right Moment

Ask for a Play Store review only after a successful session, and only
occasionally.

Good moment:

- User completes a review and frees storage or reviews a meaningful number of
  files.

Bad moments:

- First launch.
- Permission request.
- Failed deletion.
- Empty state.

Feasibility:

- Medium.
- Could use a Play review API integration later, or a simple Play Store link
  using the existing `url_launcher`.

Philosophy fit:

- Good if respectful.

Risks:

- Nagging hurts ratings.

Priority:

- Medium.

### Growth 6.5: Public Trust Page

Add a small section to the existing web landing page:

- No internet permission.
- No analytics SDK.
- No account system.
- Local SQLite only.
- Android permissions explained.

Feasibility:

- High.

Risks:

- Must stay accurate.

Priority:

- High.

### Growth 6.6: Feedback Without Tracking

Add one or both:

- "Send feedback" mailto link.
- "Copy diagnostic report" button that creates a plain-text local report the
  user can inspect before sending.

The report can include:

- App version.
- Android version.
- Device model.
- Enabled scan settings.
- Counts, not file names.
- Permission states.
- Recent error flags if any.

Feasibility:

- Medium.

Philosophy fit:

- Strong if user-triggered and visible.

Risks:

- Diagnostic text must not include private file names by default.

Priority:

- Medium-high.

## Feature Scoring Matrix

Scoring: 5 is best.

| Feature | User value | Philosophy fit | Feasibility | Trust risk | Priority |
| --- | ---: | ---: | ---: | ---: | --- |
| Permission explanation center | 4 | 5 | 5 | 1 | Must |
| Review modes | 5 | 5 | 4 | 1 | Must |
| Largest-first review | 5 | 5 | 5 | 2 | Must |
| Screenshot review | 5 | 5 | 4 | 2 | Must |
| Downloads inbox | 4 | 5 | 5 | 1 | High |
| Custom folder profiles | 4 | 5 | 4 | 2 | High |
| Exact duplicate detection | 5 | 5 | 3 | 3 | High |
| Similar photo groups | 5 | 4 | 3 | 3 | High |
| Later queue | 4 | 5 | 3 | 2 | High |
| Never ask again | 4 | 5 | 3 | 2 | High |
| Storage dashboard | 4 | 4 | 3 | 2 | High |
| Smarter reminders | 4 | 4 | 3 | 2 | Medium-high |
| Blurry photo suggestions | 3 | 3 | 2 | 4 | Later |
| App cache guidance | 3 | 4 | 3 | 2 | Later |
| Unused apps analyzer | 3 | 2 | 2 | 4 | Avoid for now |
| Cloud backup | 3 | 0 | 3 | 5 | Do not build |
| Ad-supported cleaner | 2 | 0 | 4 | 5 | Do not build |
| One-tap auto-delete | 4 | 1 | 3 | 5 | Do not build |
| All-files deep cleaner | 4 | 1 | 1 | 5 | Do not build |

Trust risk is inverted: 1 is low risk, 5 is high risk.

## Recommended Release Plan

### Release 1.1: Trust And Transparency

Goal:

Make the existing app's safety model and privacy posture more understandable.

Scope:

- Permission explanation center.
- Privacy receipt.
- Clear Epura local history action.
- Preserve and clarify the existing final deletion confirmation.
- Store listing copy refresh.

Why first:

These changes strengthen the current app without expanding technical risk.

Success criteria:

- Users understand that deletion still requires end-of-session confirmation.
- Privacy promise is visible in-app, not only in policy text.
- Store listing accurately communicates the offline/no-account promise.

### Release 1.2: Review Modes

Goal:

Make Epura useful for more concrete cleanup jobs.

Scope:

- Review modes on home screen.
- Largest-first review.
- Large video mode.
- Screenshot mode v1.
- Downloads inbox improvements.
- Per-mode summary before review.

Why second:

It gives users more reasons to open Epura without changing the core interaction.

Success criteria:

- A user can start a useful cleanup session in one or two taps.
- Screenshots and large videos are easy to target.
- Downloads import feels intentional rather than bolted on.

### Release 1.3: Local Decision Memory

Goal:

Make repeated use less repetitive.

Scope:

- Later queue.
- Never ask again.
- Local decision history table.
- Review skipped files mode.
- More detailed local stats.

Why third:

Once review modes exist, memory prevents modes from resurfacing the same files
too often.

Success criteria:

- Kept files do not keep annoying users.
- Skipped files have a clear place.
- Local history can be cleared.

### Release 1.4: Duplicate Cleanup

Goal:

Add local intelligence while preserving review safety.

Scope:

- Exact duplicate candidates.
- Similar screenshot candidates.
- Similar photo groups v1.
- Side-by-side group review.
- Hash cache in local SQLite.

Why fourth:

This is highly valuable but requires trust groundwork and careful false-positive
handling.

Success criteria:

- No automatic deletion.
- User can inspect every duplicate group.
- False positives can be dismissed permanently.

### Release 1.5: Storage Insight

Goal:

Help users understand storage without pretending to control the whole phone.

Scope:

- Local storage dashboard.
- "What is taking space?" guide.
- Android storage settings deep link.
- Monthly cleanup plan.
- Web trust page.

Why fifth:

Insight is more useful after Epura has richer review modes and decision data.

Success criteria:

- Users know what Epura can review.
- Users know what must be handled by Android settings or other apps.
- The product avoids misleading cleaner-app claims.

## Data Model Evolution

The current database stores review sessions. Future features need local state
that is more granular.

Recommended local tables:

### `review_sessions`

Keep current session table, but consider adding:

- `mode`: recent, screenshots, downloads, large_videos, folder, duplicates.
- `reviewedBytes`: total bytes reviewed.
- `sourceCounts`: optional JSON summary.

### `review_decisions`

Purpose:

Track decisions per file locally.

Fields:

- `id`
- `fileKey`
- `source`
- `decision`: keep, delete, skip, neverAskAgain.
- `decidedAt`
- `sessionId`
- `cooldownUntil`
- `sizeAtDecision`
- `displayNameHash` or no filename by default if privacy is preferred.

### `file_index`

Purpose:

Cache metadata for scan speed and grouping.

Fields:

- `fileKey`
- `source`
- `contentUri`
- `mediaStoreId`
- `size`
- `modifiedAt`
- `mimeType`
- `width`
- `height`
- `durationMs`
- `relativeBucket`
- `indexedAt`

### `media_fingerprints`

Purpose:

Cache duplicate/similarity signals.

Fields:

- `fileKey`
- `fingerprintType`: exact_hash, ahash, dhash, phash.
- `fingerprintValue`
- `createdAt`
- `algorithmVersion`

### `folder_profiles`

Purpose:

Add local metadata to selected folders.

Fields:

- `uri`
- `systemName`
- `nickname`
- `lastReviewedAt`
- `enabled`

Local data rules:

- Everything remains on device.
- Provide a clear local-history deletion option.
- Do not store thumbnails longer than needed unless cache controls are clear.
- Avoid storing raw file names in long-term analytics-like tables if not needed.

## Technical Architecture Guidance

### Keep Flutter Core, Add Native Android Only Where Needed

Flutter is fine for the product surface. Native Android should be used only for
storage APIs that Flutter plugins do not expose cleanly.

Good native candidates:

- MediaStore trash/delete requests.
- Relative path/bucket metadata for screenshot classification.
- Storage free/total space if a package is not already available.
- Android settings intents.

Avoid:

- Large native rewrite.
- Background services that scan too often.
- Accessibility-service tricks.
- All-files access unless the product strategy changes completely.

### Use Background Work Carefully

Scanning and hashing can be heavy. The UI must not freeze.

Recommendations:

- Keep current visible progress model.
- Do hash generation incrementally.
- Use isolates for CPU work where possible.
- Cache results.
- Pause heavy work on low battery if detectable without new sensitive access.
- Let users cancel scans.

### Treat Android Permissions As UX

Permission flows should explain:

- Why the permission is needed now.
- What happens if the user says no.
- How to change the setting later.
- What Epura still can do with limited access.

This matters more as Android 14+ selected photo access becomes common.

### Avoid Broad Special Permissions

Do not add:

- `MANAGE_EXTERNAL_STORAGE`.
- `QUERY_ALL_PACKAGES`.
- Usage access.
- Accessibility services.
- VPN service.
- Notification listener.
- Contacts/calendar permissions.
- Internet permission for core features.

These permissions would shift Epura from trusted cleaner to suspicious cleaner.

## UX Principles

### Home Screen

The home screen should answer:

- What can I review now?
- How much space is at stake?
- What is the safest next action?

Recommended layout:

1. App title and settings.
2. Storage/review summary card.
3. Primary action: Start Review.
4. Review modes: Screenshots, Large videos, Downloads, Folders.
5. Secondary actions: Stats, Help.

### Review Screen

The review screen should answer:

- What file is this?
- Why am I seeing it?
- How big is it?
- What happens if I delete it?
- How far through the session am I?

Recommended additions:

- Source chip: Camera, Screenshot, Downloads, Folder name.
- Full-screen preview.
- "Show details" sheet.
- Undo for latest swipe before moving too far.

### Summary Screen

The summary screen should answer:

- What did I review?
- What did I delete?
- What is pending or recoverable?
- What should I do next?

Recommended additions:

- "Moved to trash" versus "Deleted" distinction.
- "Review skipped later" CTA if skipped count is high.
- Respectful review prompt only after positive sessions.

### Settings

Settings should stay compact.

Recommended grouping:

- Review preferences.
- Folders and imports.
- Reminders.
- Privacy and permissions.
- Appearance and language.
- Legal and help.

## Copy And Tone

Use plain language. Avoid inflated cleaner-app language.

Good:

- "Review before deleting."
- "Files stay on your phone."
- "Epura can only see folders you select."
- "Large videos often free the most space."
- "This file may be gone permanently."

Avoid:

- "Deep clean your phone."
- "Boost performance."
- "Remove junk automatically."
- "AI knows what to delete."
- "Fix all storage problems."
- "Secure your phone from viruses."

## Features To Avoid

### Cloud Backup Or Sync

Why avoid:

- Violates the core philosophy.
- Requires accounts or cloud identity.
- Creates support and security obligations.
- Competes poorly with Google Photos, Drive, OneDrive, etc.

### Advertising

Why avoid:

- Storage and photo apps handle sensitive personal content.
- Ads create tracking and trust concerns.
- Reddit users specifically distrust ads in file/storage apps.

### Analytics SDKs

Why avoid:

- Contradicts "no analytics".
- Changes Data safety requirements.
- Adds third-party code and identifiers.
- Undermines privacy positioning.

### One-Tap Auto Clean

Why avoid:

- High regret risk.
- Turns Epura into the type of cleaner users distrust.
- False positives would be product-damaging.

### Broad All-Files Cleaner

Why avoid:

- Google Play restricts all-files access.
- It would require a different product identity.
- It risks making Epura feel invasive.

### Battery Booster / RAM Booster / Virus Cleaner

Why avoid:

- Misleading commodity cleaner claims.
- Does not fit current functionality.
- Attracts the wrong audience and expectations.

### Installed Apps Analyzer

Why avoid for now:

- Meaningful unused-app detection can require sensitive package/usage access.
- Android and Play policy treat broad visibility into installed apps as
  sensitive.
- Files by Google and Android Settings already cover this better.

## Popularity Strategy

Epura should grow through five channels.

### 1. Clear Store Positioning

Make the listing speak to real search intent:

- photo cleaner
- screenshot cleaner
- clean storage
- delete duplicate photos
- clean large videos
- download cleaner
- offline cleaner
- no account cleaner

Use those phrases naturally. Do not keyword-stuff.

### 2. Trust Differentiation

Make "No account. No analytics. No ads. Offline." visible in:

- First screenshot.
- Short description.
- Full description.
- Web landing page.
- In-app privacy receipt.

### 3. User Review Loop

Use Play Console:

- Monitor ratings by version.
- Read review themes.
- Reply to users.
- Prioritize issues that affect trust: deletion problems, permission confusion,
  missing previews, crashes, scan slowness.

### 4. Community-Led Learning

Continue watching Reddit and Android communities, but use them as qualitative
signals, not as product truth. Look for repeated pain:

- screenshots
- duplicates
- large videos
- downloads
- confusing storage accounting
- cleaner app distrust
- no ads/no subscription requests

### 5. Website And Public Proof

The website should be more than a badge. It should explain why Epura is safe:

- It works offline.
- It has no account.
- It has no analytics.
- It does not request all-files access.
- It asks before deleting.

## Acceptance Criteria For Future Features

Before building any new feature, answer:

1. Does it work fully offline?
2. Does it avoid accounts?
3. Does it avoid sending user data off-device?
4. Does it preserve user confirmation before deletion?
5. Does it avoid broad or surprising permissions?
6. Does it improve the current review loop?
7. Can a non-technical user understand it in one sentence?
8. Can the feature be removed later without breaking the app?
9. Is it truthful enough for the privacy policy and Play Data safety form?
10. Does it make Epura more useful without making it feel like a generic
    cleaner?

If the answer to any of the first five questions is no, the feature should not
ship.

## Recommended Immediate Next Steps

1. Write a small product spec for Release 1.1: permission explanation center,
   privacy receipt, local history clearing, and preservation of the existing
   final deletion confirmation.
2. Refresh the Google Play listing around the "asks before it deletes" and
   offline/no-account/no-analytics promise.
3. Add a simple local "clear Epura history" setting.
4. Add review modes in the smallest possible form: Recent, Screenshots, Large
   videos.
5. Build local decision memory before duplicate detection.
6. Prototype exact duplicate detection on a local test gallery.
7. Only after exact duplicates are safe, prototype perceptual hashing for
   screenshots and photos.

## Source Notes

Sources were used to ground the roadmap in current Android constraints, Google
Play requirements, competitor patterns, and user pain signals. Reddit is
included as qualitative user research, not as the only source.

### Local Repository Evidence

- `README.md`: current app description, feature list, architecture, and
  permissions.
- `web/index.html`: public positioning around local cleanup and no accounts.
- `lib/providers/file_service.dart`: media/custom folder/imported document
  scanning behavior.
- `lib/providers/review_provider.dart`: keep/delete/skip decision flow and
  deletion execution.
- `lib/providers/settings_provider.dart`: reminders, scan settings, folder
  grants, theme, locale, terms acceptance.
- `lib/screens/home_screen.dart`: review entry, lookback picker, downloads
  import, scan progress.
- `lib/screens/review_screen.dart`: swipe review flow.
- `lib/screens/stats_screen.dart`: local stats and session history.
- `android/app/src/main/AndroidManifest.xml`: permissions and absence of
  internet permission.
- `android/app/src/main/kotlin/com/epura/cleaner/MainActivity.kt`: current SAF
  folder/document picker and deletion bridge.

### Android And Google Play Sources

1. Android Developers, "Access documents and other files from shared storage."
   Used for SAF behavior, user-selected folder access, and Android 11+
   restrictions on directories such as Downloads.
   https://developer.android.com/training/data-storage/shared/documents-files

2. Android Developers, "Grant partial access to photos and videos."
   Used for Android 14 selected-photo access and Photo Picker guidance.
   https://developer.android.com/about/versions/14/changes/partial-photo-video-access

3. Android Developers, "Access media files from shared storage."
   Used for media permissions, Downloads access through SAF, trash/delete
   requests, and media-management confirmation constraints.
   https://developer.android.com/training/data-storage/shared/media

4. Android Developers, "App permissions best practices."
   Used for permission minimization and testing permission combinations.
   https://developer.android.com/training/permissions/usage-notes

5. Android Developers, "Schedule exact alarms are denied by default."
   Used for reminder strategy and exact-alarm caution.
   https://developer.android.com/about/versions/14/changes/schedule-exact-alarms

6. Google Play Console Help, "Use of All files access permission."
   Used for avoiding `MANAGE_EXTERNAL_STORAGE` in Epura's roadmap.
   https://support.google.com/googleplay/android-developer/answer/10467955

7. Files by Google Help, "How to use Files by Google."
   Used as a benchmark for common cleanup categories: duplicates, screenshots,
   recommended files, unused apps, and junk files.
   https://support.google.com/files/answer/9848742

8. Files by Google listing on Google Play.
   Used as competitive reference for cleanup recommendations, search/browse,
   offline sharing, no ads, and app size positioning.
   https://play.google.com/store/apps/details?id=com.google.android.apps.nbu.files

9. Google Play Console Help, "Metadata."
   Used for store listing guidance: clear descriptions, no misleading metadata,
   no keyword stuffing.
   https://support.google.com/googleplay/android-developer/answer/9898842

10. Google Play Console Help, "Create and set up your app."
    Used for Play Store app name, short description, full description, preview
    assets, and localization considerations.
    https://support.google.com/googleplay/android-developer/answer/9859152

11. Google Play Console Help, "App Discovery and Ranking."
    Used for the link between relevance, quality, user experience, ratings,
    reviews, and discovery.
    https://support.google.com/googleplay/android-developer/answer/9958766

12. Google Play Console Help, "View and analyse your app's ratings and
    reviews."
    Used for review monitoring and feedback-loop recommendations.
    https://support.google.com/googleplay/android-developer/answer/138230

13. Google Play Console Help, "Provide information for Google Play's Data
    safety section."
    Used for Data safety accuracy and the impact of future SDK/data-practice
    changes.
    https://support.google.com/googleplay/android-developer/answer/10787469

14. Google Play Help, "Understand app privacy and security practices with
    Google Play's Data safety section."
    Used for explaining how users see Data safety and how local-only access is
    treated.
    https://support.google.com/googleplay/answer/11416267

15. Android Developers, "What great core value looks like."
    Used for app quality, marketing accuracy, user metrics, and core value
    framing.
    https://developer.android.com/quality/core-value

16. Android Developers, "Android storage use cases and best practices."
    Used for scoped storage strategy and storage feature boundaries.
    https://developer.android.com/training/data-storage/use-cases

17. Android Developers, "AppSearch."
    Used as a possible future local-only search/indexing reference, though
    SQLite remains sufficient for most near-term Epura needs.
    https://developer.android.com/develop/ui/views/search/appsearch

### Technical Sources For Similarity Detection

18. pHash.org, "pHash documentation."
    Used for perceptual hashing concepts and limitations.
    https://phash.org/docs/howto.html

19. arXiv, "State of the Art: Image Hashing."
    Used for grounding perceptual hashing as a known approach for duplicate and
    near-duplicate image retrieval.
    https://arxiv.org/abs/2108.11794

20. arXiv, "Stuck in the Permissions With You: Developer and End-User
    Perspectives on App Permissions and Their Privacy Ramifications."
    Used for the trust impact of unnecessary permissions.
    https://arxiv.org/abs/2301.06534

21. arXiv, "Exploring the Effectiveness of Google Play Store's Privacy
    Transparency Channels."
    Used for the recommendation to align privacy policy, Data safety, and
    permission transparency instead of relying on only one channel.
    https://arxiv.org/abs/2511.13576

### Reddit And Community Research

22. Reddit, r/googleplayconsole, "I built an Android app to clean duplicate
    photos, screenshots & WhatsApp junk."
    Used for current user/developer pain around storage full, duplicate
    screenshots, WhatsApp forwards, memes, large videos, offline operation,
    aggressive ads, and confusing UI.
    https://www.reddit.com/r/googleplayconsole/comments/1t73g6d/i_built_an_android_app_to_clean_duplicate_photos/

23. Reddit, r/ShowMeYourApps, "I built Swipezy - a swipe-based gallery cleaner
    to finally make photo cleanup less painful."
    Used for validation of swipe cleanup, review-before-delete, fast scanning,
    no ads, and unsafe suggestion concerns.
    https://www.reddit.com/r/ShowMeYourApps/comments/1tn4h7l/i_built_swipezy_a_swipebased_gallery_cleaner_to/

24. Reddit, r/apps, "Any apps that are that swipe to delete storage saver
    that's completely free with no subscription?"
    Used for user frustration with subscriptions and in-app purchases in
    swipe-to-delete storage apps.
    https://www.reddit.com/r/apps/comments/1jneolz/any_apps_that_are_that_swipe_to_delete_storage/

25. Reddit, r/cellphones, "don't download cleaner apps."
    Used for distrust of cleaner apps, popups, malware-like behavior, and
    misleading booster claims.
    https://www.reddit.com/r/cellphones/comments/1hybrhn/

26. Reddit, r/privacy, "Mozilla says most top apps on Android have misleading
    privacy labels."
    Used for privacy-label skepticism and the need for in-app proof, not only
    Data safety claims.
    https://www.reddit.com/r/privacy/comments/11csjw5/mozilla_says_most_top_apps_on_android_have/

27. Reddit, r/androidapps, "Let's make a list of apps without ads."
    Used for demand around free/offline/no-ad apps and the idea that ads in
    file/storage apps are a trust red flag.
    https://www.reddit.com/r/androidapps/comments/1oizhi5/lets_make_a_list_of_apps_without_ads/

28. Reddit, r/TestersCommunity, "Swipr - Swipe to clean your photo gallery."
    Used for user/developer frustration with swipe limits, fullscreen ads, and
    high unlimited-swipe pricing.
    https://www.reddit.com/r/TestersCommunity/comments/1sqmav8/swipr_swipe_to_clean_your_photo_gallery_android/

29. Reddit, r/GooglePixel, "Pixel Image Storage Full even though all pics/vids
    are backed up."
    Used for storage confusion and "hidden storage" user pain.
    https://www.reddit.com/r/GooglePixel/comments/k8jieb/pixel_image_storage_full_even_though_all_picsvids/

30. Reddit, r/GooglePixel, "Storage full ever since I bought a Pixel."
    Used for large video/storage-growth pain and user need to avoid repeated
    manual cleanup.
    https://www.reddit.com/r/GooglePixel/comments/18y11q3/storage_full_ever_since_i_bought_a_pixel/

31. Reddit, r/ProductivityApps, "Screenshot Cleaner - Automatically find and
    delete screenshots and duplicate captures."
    Used for screenshot clutter patterns: receipts, chats, memes, temporary
    info, and demand for fast minimal screenshot cleanup.
    https://www.reddit.com/r/ProductivityApps/comments/1qrs3eq/app_screenshot_cleaner_automatically_find_delete/

32. Reddit, r/SideProject, "How SnapSilo detects duplicate screenshots without
    a ML model."
    Used for a lightweight perceptual-hashing approach to similar screenshot
    detection and the caution that thresholds can produce false positives.
    https://www.reddit.com/r/SideProject/comments/1tjvjr7/how_snapsilo_detects_duplicate_screenshots/

33. Reddit, r/YouShouldKnow, "YSK that Play Store lets apps lie about what
    data they collect."
    Used as qualitative evidence of user skepticism around Data safety claims.
    https://www.reddit.com/r/YouShouldKnow/comments/1soa3yg/ysk_that_play_store_lets_apps_lie_about_what_data/

34. Reddit, r/androiddev, "Need Advice: Water Reminder App Notifications -
    Exact vs Inexact Alarms."
    Used as developer-community evidence that reminders face practical
    exact-alarm tradeoffs on modern Android.
    https://www.reddit.com/r/androiddev/comments/1ncrkji/need_advice_water_reminder_app_notifications/

35. Reddit, r/googlephotos, "Photos barely take up space despite storage being
    full."
    Used for cloud/device storage confusion and why Epura should distinguish
    local device cleanup from cloud quota cleanup.
    https://www.reddit.com/r/googlephotos/comments/1sur6w1/photos_barely_take_up_space_despite_storage_being/

### Competitor And Market References

36. Favvy, "Clean your gallery, just by swiping."
    Used as competitive reference for offline swipe cleanup, review-before-delete
    positioning, screenshot mode, and Android recovery caveats.
    https://www.favvyapp.com/en
