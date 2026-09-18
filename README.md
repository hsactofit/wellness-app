# WellnessConnect

Shared Flutter member app for Medifit and Mednovations.

## Mednovations Face Scan pilot

Face Scan is excluded from normal builds. To compile the pilot UI explicitly:

```bash
flutter run --flavor mednovations \
  --dart-define=APP_BRAND=mednovations \
  --dart-define=FACE_SCAN_ENABLED=true
```

The runtime API must independently enable the same Mednovations pilot. Camera
permission is separate from explicit video-processing consent. Recordings use
the front camera for 30 seconds with audio disabled and are deleted locally
after upload or cancellation.

Use the project-local Flutter SDK at `../.tools/flutter/bin/flutter`. Do not use
Homebrew or add global dependencies.
