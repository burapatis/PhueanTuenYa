# SRS Traceability v0.2.5 — Edit/Delete Mock Flow

## Version goal
Add mock CRUD flows before local persistence so users can add, view, edit, and delete records in every main module.

## SRS alignment
- Full User Ownership: users can add, view, edit, and delete their own data.
- Elderly-friendly UI: action buttons use short Thai words, icon labels, large touch targets, and confirmation alerts for delete.
- Medical disclaimer remains visible in module safety notes.
- Offline-first remains unchanged: this version is still in-memory only, with no backend and no login.

## Implemented mock CRUD
- Medication: edit/delete medication list, delete medication log.
- Blood pressure: edit/delete blood pressure records.
- Symptom/feeling: edit/delete symptom records.
- Health calendar: edit/delete appointment records.
- SOS contacts: edit/delete contacts, preserve primary contact behavior.
- Settings: clear-all mock data remains protected by confirmation alert.

## Known limitation
This is still an in-memory prototype. Data is lost after app restart. Next major milestone should be SwiftData local persistence after UX is validated.
