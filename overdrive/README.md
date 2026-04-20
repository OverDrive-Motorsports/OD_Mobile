# OverDrive

Application Flutter minimaliste avec une seule page `Home`.

Documentation détaillée :

- `ARCHITECTURE_LIB.md`

## Structure actuelle

- `lib/main.dart` lance directement `HomePage`
- `lib/pages/home/home_page.dart` contient uniquement le fond de page et le menu
- `lib/widgets/menu_overlay.dart` affiche `OD`, le bouton `Menu` et l'action `Health`
- `lib/services/health_service.dart` gère l'unique interaction backend: `GET /health`
- `lib/core/theme/app_theme.dart` centralise le thème et les styles

## Backend

La seule interaction backend conservée est:

- `GET /health`

L'URL du backend est lue depuis `API_BASE_URL` si elle est définie. Sinon l'application utilise:

- `http://10.0.2.2:8080` sur Android
- `http://localhost:8080` ailleurs

## Tests

Le test widget vérifie que la home affiche bien `OD` et le bouton `Menu`.
