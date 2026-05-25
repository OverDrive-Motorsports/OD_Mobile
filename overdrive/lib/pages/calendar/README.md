# Calendar Page

## Purpose

`calendar_page.dart` renders the calendar screen from the temporary calendar service.
It combines championship filters, a reusable monthly calendar, and event cards.

## Responsibilities

- Load championship and schedule data from `CalendarService`.
- Keep filter, selected date, loading, and archive state local to the route.
- Compose reusable calendar widgets instead of embedding all rendering in the page.
- Keep date labels and display formatting close to the page-level locale choices.

## Dependencies

- `CalendarService` from `services/calendar`.
- `MonthlyCalendar` and `EventCalendar` from `widgets/calendar`.
- `GlassPill` for compact filter and archive controls.
- `MenuOverlay` for top-level navigation.

## Extension Notes

- Replace the mock backend with the real schedule source behind `CalendarService`.
- Keep future filters declarative and avoid duplicating event-card rendering in the page.
