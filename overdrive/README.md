# OverDrive Mobile

Application mobile Flutter du projet OverDrive.

## Prerequisites

- Flutter SDK installe
- Dart SDK disponible dans le PATH

## Installation

```bash
flutter pub get
```

## Environment Configuration

Le projet utilise `flutter_dotenv` avec deux fichiers:

- `.env` (developpement)
- `.env.prod` (production)

Variables attendues:

- `API_BASE_URL`
- `APP_ENV`

Le chargement de l'environnement se fait dans `lib/main.dart`:

- par defaut: `.env`
- surcharge possible avec `--dart-define=ENV_FILE=.env.prod`

## Run

Developpement:

```bash
flutter run
```

Production (fichier prod):

```bash
flutter run --dart-define=ENV_FILE=.env.prod
```

## Quality

Lint:

```bash
flutter analyze
```

Format:

```bash
dart format lib/
```

Configuration associee:

- `analysis_options.yaml`
- `.editorconfig`

## Notes

- `.env` et `.env.prod` sont ignores par Git.
- Les assets Flutter incluent `.env` et `.env.prod` via `pubspec.yaml`.
