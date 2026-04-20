# OverDrive

Application Flutter minimaliste centrée sur une page `Home` et plusieurs pages placeholders accessibles depuis le menu.

Documentation détaillée :

- `ARCHITECTURE_LIB.md`

## Structure actuelle

- `lib/main.dart` lance directement `HomePage` et configure le thème global
- `lib/pages/home/home_page.dart` affiche l'écran d'accueil avec fond noir uni
- `lib/widgets/menu_overlay.dart` affiche `OD`, le bouton `Menu`, les raccourcis de navigation et l'action `Health`
- `lib/pages/shared/placeholder_page.dart` fournit un écran placeholder réutilisable avec titre centré
- `lib/pages/profile/profile_page.dart` affiche la page `Profil`
- `lib/pages/settings/settings_page.dart` affiche la page `Settings`
- `lib/pages/calendar/calendar_page.dart` affiche la page `Calendar`
- `lib/pages/championship/championship_page.dart` affiche la page `Championship`
- `lib/pages/tv/tv_page.dart` affiche la page `TV`
- `lib/pages/telemetry/telemetry_page.dart` affiche la page `Telemetry`
- `lib/pages/search/search_page.dart` affiche la page `Search`
- `lib/services/health_service.dart` gère l'unique interaction backend: `GET /health`
- `lib/core/theme/app_theme.dart` centralise le thème, les couleurs et les styles

## Convention de header

Tous les fichiers Dart dans `lib/` commencent désormais par le header standard suivant, adapté à chaque fichier :

```dart
/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [FileName] - [Brief description of the file's purpose]
 ##
 */
```

## Backend

La seule interaction backend conservée est:

- `GET /health`

L'URL du backend est lue depuis `API_BASE_URL` si elle est définie. Sinon l'application utilise:

- `http://10.0.2.2:8080` sur Android
- `http://localhost:8080` ailleurs

## Tests

Le test widget historique vérifie que la home affiche bien `OD` et le bouton `Menu`.

## Qualité de code

Commandes utiles :

```bash
dart format lib
flutter analyze
```
