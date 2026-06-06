# TestFlight Build Settings Checklist — เพื่อนเตือนยา iOS v0.6.6

## Version / Build
- Version: 0.6.6
- Build: 66
- Suggested tag after passing: phuean-tuenya-ios-v0.6.6

## Xcode settings to verify
- Bundle Identifier: use the App Store Connect registered bundle ID, e.g. `com.phueanteuanya.PhueanTuenYa` or the final ID assigned to this app.
- Signing: Automatically manage signing.
- Team: Apple Developer Program team.
- Device destination before Archive: Any iOS Device.
- App category: Medical / Health-related helper, with clear disclaimer that it is not a medical device.

## Archive flow
1. Product > Clean Build Folder
2. Select Any iOS Device
3. Product > Archive
4. Organizer > Distribute App
5. App Store Connect > Upload
6. Wait for processing in App Store Connect
7. Add testers in TestFlight

## Beta review notes draft
เพื่อนเตือนยา is a local-first reminder and logging app for older adults and caregivers. It helps users record medication reminders, blood pressure, feelings/symptoms, health appointments, SOS contacts, and export CSV/PDF by user action. The app has no login, no backend, no cloud sync, and does not diagnose, analyze disease, or replace medical advice.

## Pre-upload test checklist
- First launch consent and usage guide work.
- SwiftData persists data after app restart.
- Medication and health calendar local notifications work.
- SOS opens the phone app after confirmation.
- CSV/PDF export and Share Sheet work.
- Delete all data works.
