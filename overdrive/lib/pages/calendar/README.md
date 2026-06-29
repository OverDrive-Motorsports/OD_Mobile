# Calendar Page

## Purpose

`calendar_page.dart` renders the calendar screen. It loads multi-championship race
schedules from `CalendarService`, applies a championship filter, and composes a
monthly calendar grid with event cards.

---

## Responsibilities

- Load championship list and race schedule from `CalendarService` on first build.
- Own local state for: active filter, selected date, loading flag, and archive toggle.
- Resolve the initial selected date via `resolveCalendarSelection` so the calendar
  opens on the nearest upcoming event rather than today.
- Compose `MonthlyCalendar` and `EventCalendar` without embedding rendering logic.

---

## Dependencies

- `CalendarService` from `services/calendar/calendar_service.dart`.
- `MonthlyCalendar` and `EventCalendar` from `widgets/calendar/`.
- `NavigationShell` / bottom nav provided by the GoRouter shell route.
- Theme tokens from `app_theme.dart`.

---

## Extension Notes

- Replace the mock backend in `CalendarMockBackend` with the real API without
  changing the page — `CalendarService` is the abstraction boundary.
- Keep future filter logic in `_applyFilter` to avoid scattering it across the widget tree.
- Additional championship categories (e.g. IndyCar) only require new entries in
  `CalendarMockBackend._championships`.
