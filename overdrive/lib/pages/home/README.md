# Home Page

## Purpose

`home_page.dart` is the root scaffold for the `/` route. It currently serves as the
entry screen into the app, rendered inside the `NavigationShell` bottom nav tab 0.
It provides a stable container for future homepage content.

---

## Responsibilities

- Host the root scaffold for the home route.
- Maintain visual consistency with the global dark theme.
- Render placeholder or live homepage content sections as features are added.

---

## Dependencies

- `AppColors` and `AppTextStyles` from `app_theme.dart`.
- `NavigationShell` provides the bottom navigation frame (injected by GoRouter).

---

## Extension Notes

- Add homepage sections (e.g. hero race card, latest news, quick stats) directly inside
  the scaffold body without moving the page shell.
- Keep business logic and data fetching outside `HomePage` — pass data through
  dedicated models or `ChangeNotifier` providers.
