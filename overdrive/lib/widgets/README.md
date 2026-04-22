# Widgets

Ce dossier regroupe les widgets UI partages de l'application OverDrive.

L'idee est simple :
- `widgets/` contient les briques reutilisables de l'interface
- les pages consomment ces widgets, mais ne dupliquent pas leur rendu
- quand un comportement est specifique a une page, il doit rester dans la page ou dans un hook/service dedie

<br>



## `glass_pill.dart`

Primitive visuelle reutilisable pour les boutons et champs au style "pill".

Responsabilites :
- appliquer le fond semi-transparent
- gerer la bordure normale, focus/highlight et disabled
- centraliser le style partage entre plusieurs widgets

Utilisation typique :
- bouton menu
- barre de recherche
- futurs boutons compacts ou controles flottants

<br>

## `search_bar.dart`

Barre de recherche reutilisable et purement presentational.

Responsabilites :
- afficher l'icone de recherche
- afficher le champ texte
- afficher l'action de clear sous forme de bouton externe quand le champ est focus ou non vide
- exposer des callbacks typés au parent

Ce widget ne doit pas :
- faire d'appel API
- connaitre la page dans laquelle il est rendu
- contenir une logique metier de recherche

API principale :
- `SearchBar`
- `SearchBarProps`

Props disponibles :
- `controller`
- `onSearch`
- `onClear`
- `placeholder`
- `enabled`
- `autofocus`
- `focusNode`
- `textInputAction`

<br>

## `menu_overlay.dart`

Overlay de navigation affiche au-dessus des pages.

Responsabilites :
- afficher le logo `OD`
- afficher le bouton `Menu`
- ouvrir/fermer le panneau flottant
- proposer des actions rapides de navigation
- afficher l'etat de health du backend via `HealthService`

Ce fichier contient plusieurs widgets lies entre eux :
- `MenuOverlay`
- `MenuButton`
- `MenuPanel`
- `MenuAction`
- `MenuEntry`

<br>

## `monthly_calendar.dart`

Calendrier mensuel reutilisable et decouple des pages.

Responsabilites :
- afficher une vue complete du mois
- gerer la navigation verticale entre les mois avec `PageView`
- exposer une API typed pour la date selectionnee et les callbacks
- rester volontairement minimal dans son rendu

API principale :
- `MonthlyCalendar`

Props disponibles :
- `selectedDate`
- `initialMonth`
- `eventsByDate`
- `onDateSelected`
- `onMonthChanged`
- `isLoading`
- `firstAvailableMonth`
- `lastAvailableMonth`
- `today`
- `weekdayLabels`
- `monthLabelBuilder`

<br>

## `weekly_calendar.dart`

Calendrier hebdomadaire reutilisable et decouple des pages.

Responsabilites :
- afficher une semaine sur une seule ligne
- gerer la navigation horizontale entre les semaines avec `PageView`
- exposer une API typed pour la date selectionnee et les callbacks
- rester minimal dans son rendu pour etre rebranche facilement ailleurs

API principale :
- `WeeklyCalendar`

Props disponibles :
- `selectedDate`
- `initialDate`
- `eventsByDate`
- `onDateSelected`
- `onWeekChanged`
- `isLoading`
- `firstAvailableDate`
- `lastAvailableDate`
- `today`
- `weekdayLabels`
- `weekLabelBuilder`

<br>

## `daily_calendar.dart`

Calendrier journalier reutilisable et decouple des pages.

Responsabilites :
- afficher une seule journee a la fois
- gerer la navigation horizontale entre les jours avec `PageView`
- exposer une API typed pour la date selectionnee et les callbacks
- permettre au parent de fixer facilement les bornes de navigation

API principale :
- `DailyCalendar`

Props disponibles :
- `selectedDate`
- `initialDate`
- `eventsByDate`
- `onDateSelected`
- `onDayChanged`
- `isLoading`
- `firstAvailableDate`
- `lastAvailableDate`
- `today`
- `dayLabelBuilder`
- `weekdayLabelBuilder`

<br>

## Regles de dossier

- privilegier des widgets reutilisables et bien isoles
- garder les props explicitement typées
- eviter d'injecter de la logique metier dans les primitives UI
- extraire le style partage dans un widget commun quand plusieurs composants se ressemblent

<br>

## Convention recommande

Avant d'ajouter un nouveau widget ici, se demander :
- est-ce que ce composant pourra etre reutilise ailleurs ?
- est-ce qu'il reste presentational ou au moins bien decouple ?
- est-ce qu'une partie de son style devrait etre factorisee comme `GlassPill` ?
