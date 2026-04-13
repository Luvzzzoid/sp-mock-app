# Social Production Mock App

This repo is a standalone mock Flutter app built from the prototype web app and the final app flow packs.

It is intentionally fake-data only.

There is no backend, no blockchain, no gRPC, and no real persistence.

The goal is to give you a clickable private mock that you can use to:

- look around the current product direction
- test layout and flow decisions
- notice what feels wrong before changing the planning docs
- keep mock exploration out of the real app repo

## What is inside

This mock app uses:

- Flutter
- local fake data from `lib/src/mock_data.dart`
- shared theme tokens from `lib/src/mock_theme.dart`
- branding assets from `assets/brand/`
- desktop-friendly mock layouts that follow the prototype web app

Current clickable areas include:

- main feed
- project detail pages
- thread detail pages
- production and distribution plan views
- create project flow
- create thread flow
- create community flow
- create channel flow

## How to open it

From the `mock app` folder run:

```bash
flutter pub get
flutter run -d windows
```

If you want Flutter to choose the default desktop device automatically, you can also run:

```bash
flutter run
```

## Validation

To make sure the mock still passes static checks:

```bash
flutter analyze
```

## How to use it

Start on the main feed.

From there you can click through the UI to open:

- projects
- threads
- plans
- create flows

Some controls are locally interactive in the running app session, including:

- vote toggles
- project demand signal toggles
- RSVP toggles on project events
- project tab switching

These interactions are mock-only and reset on restart.

## Mock-data notes

All content comes from:

- `lib/src/mock_data.dart`

That file controls:

- project types and accents
- stages
- users
- channels
- communities
- projects
- threads
- comments
- plans
- notifications

If you want to change what the app shows without editing the UI structure, start there first.

## Project-family rule in this mock

This mock reflects the current rule that:

- threads are their own content family
- production and service are the two explicit project types
- service still comes through the create-project flow
- service opens directly into ongoing request flow rather than researching
- channels and communities discover projects by tagged-project relationships rather than by owning the projects
- communities are discoverable spaces tagged to projects and discussion threads, not to a single dedicated channel
- projects with fund drives also have approved production and distribution plans

## Relationship language in this mock

Use the following wording when changing the mock:

- channels and communities are tagged to projects
- projects are linked to projects
- assets can be tied to land assets
- stewardship is only for platform or network software governance and collective-fund execution
- land-management services are separate service projects and land-related plans route through them explicitly

## Important limitation

This repo is not the real app and should not be treated as implementation truth.

It is a design-and-flow sandbox for private review.
