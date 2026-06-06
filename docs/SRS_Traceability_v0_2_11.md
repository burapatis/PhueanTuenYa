# SRS Traceability v0.2.11

## Focus
Consent screen compact layout polish.

## Changes
- Consent screen re-shown using a new AppStorage key for retesting.
- Removed scrolling from the consent screen.
- Condensed consent content into compact rows so the user can see all key conditions before pressing accept.
- Kept required messages: not a medical device, local-only data, user control of data, emergency guidance including 1669 and SOS/ผู้ติดต่อ.

## SRS alignment
- First-launch consent flow: full screen, cannot proceed until accepted.
- Medical disclaimer: app is only a reminder/logging helper, not diagnosis or medical advice.
- Privacy: no login/backend, local-only wording.
- SOS safety: tells user to use SOS/ผู้ติดต่อ in emergencies alongside doctor/hospital/1669.
