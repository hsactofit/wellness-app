# Mednovations Firebase configuration

Download the iOS `GoogleService-Info.plist` for the Mednovations Firebase app
whose bundle ID is `com.mednovations.wellness`, and save it in this directory
as `GoogleService-Info.plist`.

The Xcode build intentionally fails when that file is absent. This prevents a
Mednovations binary from accidentally connecting to the Medifit Firebase
project and authentication users.
