# RECO: Review · Explore · Choose · Optimize

Reco is a study-planning mobile app that helps students discover the best-fit courses for their goals. It combines a student’s transcript and interests with course information and peer feedback to guide semester planning.

## What this app does
- Personalized course discovery based on goals and academic background
- Course summaries and outcomes to support better decisions
- Student feedback and ratings to share real experiences

## Repository layout
- TODO

## Frontend (Flutter)
### Requirements
- [Install Flutter SDK](https://docs.flutter.dev/install/manual)
- [Install Android Studio](https://developer.android.com/studio)
- [Install the Flutter plugin](https://docs.flutter.dev/tools/android-studio)

### Setup
1. Copy the environment file:
   ```bash
   cp frontend/.env.example frontend/.env
   cp frontend/.env.example.json frontend/.env.json
   ```
2. Fill in your project settings in `frontend/.env` and `frontend/.env.json`. Note that `frontend/.env` is deprecated and is only used in tests
3. Verify your setup:
   ```bash
   flutter doctor
   ```
4. Open Run > Edit configurations... and add 
   ```bash
   --dart-define-from-file=.env.json
   ```
   to `Additional run args` to enable reading settings from .env.json during debug running.

### Run
```bash
cd frontend
flutter run
```

### Emulators / devices
```bash
flutter emulators
flutter devices
```


## Backend (Appwrite / Python)
### Requirements
- Python 3.12+
- [uv](https://docs.astral.sh/uv/) - Fast Python package installer and resolver

### Install uv
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
irm https://astral.sh/uv/install.ps1 | iex
```

### Setup
1. Copy the environment file:
   ```bash
   cp backend-appwrite/.env.example backend-appwrite/.env
   ```
2. Fill in the environment variables in `backend-appwrite/.env`.
3. Install dependencies:
   ```bash
   cd backend-appwrite
   uv sync
   ```

### Run

#### Android
Run 
```bash
flutter build apk  --release --obfuscate --split-debug-info=./debug_info --dart-define-from-file=.env.json
```
to build an Android APK in release mode.

## Contributing
See `CONTRIBUTING.md` for guidelines.
