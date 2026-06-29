# Search Page

## Purpose

`search_page.dart` is a lightweight search screen shell built around the shared search bar widget.

## Responsibilities

- Own the local text controller lifecycle.
- Compose the shared `SearchBar` widget.
- Keep search presentation separate from future search data or service logic.

## Dependencies

- `AppSearchBar` from `widgets/base/search_bar.dart`.
- `NavigationShell` provides the bottom navigation frame (injected by GoRouter).
- Theme tokens from `app_theme.dart`.

## Extension Notes

- Wire real search behavior through callbacks instead of embedding service logic in the widget tree.
- Move result rendering into reusable widgets if the screen grows.
