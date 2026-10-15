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
permission is separate from explicit video-processing consent. The embedded web scanner records using the front camera for 30 seconds with
audio disabled. The app opens the prefilled form using a scoped session and
reads the saved report from the API.

Use the project-local Flutter SDK at `../.tools/flutter/bin/flutter`. Do not use
Homebrew or add global dependencies.

For local testing, set `FACE_SCAN_WEB_ORIGIN=https://<mac-ip>:8443` alongside
`API_BASE_URL` and trust the local development certificate on the device.
See [the integration guide](../medifit-wellness-kb/MEDNOVATIONS_WEB_FACE_SCAN.md)
for the full setup and acceptance checks.
