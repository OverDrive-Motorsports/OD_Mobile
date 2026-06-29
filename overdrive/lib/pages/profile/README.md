# Profile Page

## Purpose

`profile_page.dart` renders the user profile screen. It displays an identity hero card,
a provider connection section, and quick-action shortcuts (edit, share, sign out).
All modal copy and action metadata are kept in immutable definitions rather than scattered
through the widget tree.

---

## Files

- `profile_page.dart` — the full profile screen; also exports `profilePagePreviewData`
  (the fallback data used by the router before a real user session is available).

---

## Data Models (defined in the same file)

| Model | Purpose |
|-------|---------|
| `ProfilePageData` | Top-level payload consumed by the page |
| `ProfileUserData` | Displayed identity (pseudo, email) |
| `ProfileProviderData` | Reserved structure for connected third-party providers |
| `ProfileActionDefinition` | Typed quick-action row definition (label, icon, type) |

---

## Dependencies

- `AppButton`, `AppModal`, `AppToast` from `widgets/base/`.
- `SettingsPage` and `SubscriptionPage` embedded as tab content.
- Theme tokens from `app_theme.dart`.

---

## Extension Notes

- Replace `profilePagePreviewData` with live route or state-managed data when backend
  authentication is ready.
- Add provider list rendering by extending `ProfileProviderData` and the provider section
  in `_ProvidersSection` without changing the hero or quick-action layout.
- Keep all user-facing strings in the immutable `_profilePageContent` constant.
