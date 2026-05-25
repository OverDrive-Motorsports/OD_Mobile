# Home Page

## Purpose

`home_page.dart` provides the current shell for the app entry screen.
Right now it intentionally stays minimal and only renders the shared menu overlay.

## Responsibilities

- Host the root scaffold for the home route.
- Keep the page visually consistent with the global theme.
- Provide a stable place for future homepage content.

## Dependencies

- `AppColors` and `AppTextStyles` from the shared theme.
- `MenuOverlay` for global navigation.

## Extension Notes

- Add homepage sections inside the existing scaffold body.
- Keep business logic outside the page when possible and pass data in through dedicated models.
