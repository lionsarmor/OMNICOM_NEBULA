# OMNICOM Nebula Frontend

Flutter client for the OMNICOM Nebula boilerplate.

The root project is Docker-first. From the repository root, run:

```bash
./dev.sh
```

For local Flutter development outside Docker:

```bash
flutter pub get
flutter run -d chrome \
  --dart-define=BACKEND_URL=http://localhost:4400 \
  --dart-define=API_BASE_URL=http://localhost:4400/api \
  --dart-define=BACKEND_WS_BASE=http://localhost:4400
```

The web Docker image bakes those same values into the release build.
