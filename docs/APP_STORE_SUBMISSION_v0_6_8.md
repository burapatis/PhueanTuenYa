# App Store Connect — Submit for Review (v0.6.8)

เอกสารนี้เตรียมข้อมูลสำหรับกรอกใน **App Store Connect** ก่อนกด **Submit for Review**  
อ้างอิงจากโค้ดจริงในโปรเจกต์ PhueanTuenYa v0.6.8 (Build 70)

---

## 1) ข้อมูลพื้นฐานแอป

| รายการ | ค่าที่ใช้ |
|--------|----------|
| **ชื่อแอป (บนเครื่อง)** | เพื่อนเตือนยา |
| **ชื่อใน App Store Connect** | Phuean Tuean Ya (หรือ เพื่อนเตือนยา ถ้า ASC รองรับภาษาไทย) |
| **Bundle ID** | `com.phueanteuanya.PhueanTuenYa` |
| **SKU** | `phuean-tuenya-ios` |
| **เวอร์ชัน** | 0.6.8 |
| **Build ที่ส่ง** | 70 (หรือ build ล่าสุดที่สถานะ Ready to Submit) |
| **หมวดหมู่หลัก** | Healthcare & Fitness |
| **หมวดหมู่รอง (แนะนำ)** | Medical |
| **ภาษาหลัก** | Thai |
| **รองรับ iOS** | 17.0 ขึ้นไป |
| **อุปกรณ์** | iPhone, iPad |
| **ราคา** | Free |
| **In-App Purchase** | ไม่มี |
| **บัญชีผู้ใช้ / Login** | ไม่มี |
| **GitHub (Support URL แนะนำ)** | https://github.com/burapatis/PhueanTuenYa |
| **Privacy Policy URL** | https://burapatis.github.io/app/apps/pheuan-tueanya/privacy.html |
| **Terms of Use URL** | https://burapatis.github.io/app/apps/pheuan-tueanya/terms.html |
| **Help / Support page** | https://burapatis.github.io/app/apps/pheuan-tueanya/support.html |

---

## 2) ข้อความสำหรับหน้า App Store (ภาษาไทย)

### Subtitle (สูงสุด 30 ตัวอักษร)
```
เตือนยาและบันทึกสุขภาพ
```
*(29 ตัวอักษร)*

### Promotional Text (ไม่บังคับ — แก้ได้โดยไม่ต้องส่ง review ใหม่)
```
เตือนกินยา บันทึกความดัน อาการ นัดหมาย และ SOS ข้อมูลอยู่ในเครื่อง ไม่ต้องสมัครสมาชิก
```

### Description (คำอธิบายแอป)
```
เพื่อนเตือนยา เป็นแอปช่วยเตือนกินยาและบันทึกข้อมูลสุขภาพในเครื่อง ออกแบบให้ผู้สูงอายุและผู้ดูแลใช้งานง่าย แตะเลือกเป็นหลัก ลดการพิมพ์

ฟีเจอร์หลัก
• ยา — เพิ่มรายการยา เลือกเวลาเตือน บันทึกการกินยาในวันนี้ และดูความคืบหน้า
• ความดัน — บันทึกค่าความดันและชีพจรตามที่ผู้ใช้วัดได้ พร้อมหมายเหตุ
• ความรู้สึกและอาการ — เลือกความรู้สึกวันนี้และอาการที่พบแบบแตะ
• ปฏิทินสุขภาพ — เพิ่มนัดหมายและตั้งการแจ้งเตือนล่วงหน้า
• SOS/ผู้ติดต่อ — เก็บผู้ติดต่อฉุกเฉิน และเปิดแอปโทรศัพท์หลังยืนยัน
• ตั้งค่า — ส่งออก CSV/PDF ดูข้อตกลง วิธีใช้ และล้างข้อมูลเมื่อจำเป็น

ความเป็นส่วนตัว
• ข้อมูลบันทึกอยู่ในเครื่องของผู้ใช้ด้วย SwiftData
• ไม่มีระบบสมัครสมาชิก ไม่มี backend ไม่มีการซิงก์คลาวด์
• ผู้พัฒนาไม่สามารถเข้าถึงหรือดูข้อมูลที่ผู้ใช้บันทึกได้
• การส่งออกไฟล์ทำได้เมื่อผู้ใช้กดเองเท่านั้น

ข้อจำกัดสำคัญ
แอปนี้ไม่ใช่เครื่องมือแพทย์ ช่วยเตือนและบันทึกเท่านั้น ไม่วิเคราะห์ ไม่วินิจฉัย และไม่ให้คำปรึกษาทางการแพทย์ กรณีผิดปกติหรือฉุกเฉิน โปรดติดต่อแพทย์ โรงพยาบาล โทร 1669 หรือใช้เมนู SOS
```

### Keywords (สูงสุด 100 ตัวอักษร — คั่นด้วย comma ไม่มีช่องว่างหลัง comma)
```
เตือนยา,ยา,สุขภาพ,ผู้สูงอายุ,ความดัน,นัดหมาย,SOS,บันทึกสุขภาพ,ผู้ดูแล
```
*(ตรวจนับอักขระก่อนบันทึก — ปรับได้ตามนโยบาย ASC)*

### What's New in This Version (0.6.8)
```
• ปรับหน้าข้อตกลงก่อนใช้งาน: เพิ่มลิงก์นโยบายความเป็นส่วนตัวและข้อกำหนดการใช้งาน
• ต้องติ๊กยืนยันว่าอ่านและยอมรับข้อตกลงก่อนกดปุ่มยินยอม
• ปรับหน้าวิธีใช้งาน: เพิ่มการ์ดการบันทึกข้อมูลและลิงก์ความช่วยเหลือ
• คงฟีเจอร์หลักครบ: เตือนยา บันทึกสุขภาพ นัดหมาย SOS และส่งออก CSV/PDF
• ข้อมูลยังคงอยู่ในเครื่อง ไม่มี backend
```

### Support URL (บังคับ)
```
https://github.com/burapatis/PhueanTuenYa
```

### Marketing URL (ไม่บังคับ)
```
https://burapatis.github.io/app/apps/pheuan-tueanya/support.html
```

### Copyright
```
© 2026 Boorapatis Ploysuwan
```

---

## 3) ข้อความภาษาอังกฤษ (ถ้าเพิ่ม Localization EN)

### Subtitle
```
Medication & health log
```

### Description (สรุป)
```
Puean Tuean Ya is a local-first app that helps users set medication reminders and log health information on their device. Designed for older adults and caregivers with a tap-first Thai interface.

Features: medication reminders and logs, blood pressure records, feelings/symptoms, health appointments, SOS contacts, and manual CSV/PDF export.

All data stays on the device. No account, no backend, no cloud sync. The developer cannot access user data.

This app is not a medical device. It does not diagnose, analyze, or provide medical advice. In an emergency, contact a doctor, hospital, or call 1669.
```

### Keywords
```
medication,reminder,health,elderly,blood pressure,caregiver,SOS,Thai
```

---

## 4) App Privacy (คำถามความเป็นส่วนตัว)

ตอบตามพฤติกรรมจริงของแอป (`PrivacyInfo.xcprivacy` + โค้ด)

### การติดตาม (Tracking)
- **Do you or your third-party partners track users?** → **No**

### การเก็บข้อมูล (Data Collection)
แอปประกาศ `NSPrivacyCollectedDataTypes` ว่าง — ข้อมูลสุขภาพเก็บในเครื่องเท่านั้น ไม่ส่งให้ developer

**แนะนำตอบใน App Privacy Questionnaire:**

| ประเภทข้อมูล | เก็บหรือไม่ | เชื่อมกับตัวตนผู้ใช้ | ใช้เพื่อ Tracking | หมายเหตุ |
|-------------|------------|---------------------|-------------------|----------|
| Health (ยา ความดัน อาการ นัดหมาย) | **ไม่ส่งออกจากอุปกรณ์** | — | No | เก็บใน SwiftData บนเครื่อง |
| Contact Info (SOS เบอร์โทร) | **ไม่ส่งออกจากอุปกรณ์** | — | No | ผู้ใช้กรอกเอง |
| User Content | **ไม่ส่งออกจากอุปกรณ์** | — | No | บันทึกในเครื่อง |
| Identifiers / Analytics | **ไม่มี** | — | No | ไม่มี analytics SDK |

**สรุปสั้น ๆ สำหรับ ASC:**
> **Data Not Collected** — ข้อมูลที่ผู้ใช้บันทึกอยู่ในเครื่องเท่านั้น แอปไม่ส่งข้อมูลไปยังเซิร์ฟเวอร์ของผู้พัฒนา

### Required Reason API (ใน Privacy Manifest แล้ว)
- UserDefaults — CA92.1 (AppStorage สำหรับ consent/guide flags)
- File timestamp — C617.1 (ไฟล์ export ชั่วคราว)

---

## 5) Age Rating (การจัดเรตอายุ)

ตอบแบบสอบถามตามความเป็นจริง:

| หัวข้อ | คำตอบแนะนำ |
|--------|-----------|
| Cartoon/Fantasy Violence | None |
| Realistic Violence | None |
| Sexual Content | None |
| Profanity | None |
| Drugs/Alcohol/Tobacco | **Infrequent/Mild** (อ้างอิงยาเพื่อเตือนกินยา ไม่ส่งเสริมการใช้ยา) |
| Medical/Treatment Info | **Infrequent/Mild** (บันทึกสุขภาพที่ผู้ใช้กรอกเอง มี disclaimer ชัด) |
| Gambling | None |
| Horror/Fear | None |
| Mature/Suggestive | None |
| Unrestricted Web Access | No |
| User-Generated Content | No (ข้อมูลส่วนตัวในเครื่อง ไม่แชร์สาธารณะ) |

**เรตที่คาดได้:** 4+

---

## 6) App Review Information

### Contact Information
| ช่อง | ค่าแนะนำ |
|------|----------|
| First Name | Boorapatis |
| Last Name | Ploysuwan |
| Phone | (เบอร์ติดต่อจริงของคุณ) |
| Email | burapatis@gmail.com |

### Notes (ภาษาอังกฤษ — สำคัญสำหรับ Health app)
```
App Name: Puean Tuean Ya (เพื่อนเตือนยา)
Version: 0.6.8

SUMMARY
This is a local-first medication reminder and personal health logging app for older adults and caregivers in Thailand. All data is stored on-device using SwiftData. There is no login, no backend, no cloud sync, no HealthKit, and no third-party analytics.

HOW TO TEST (no demo account required)
1. Launch the app — first-run consent screen appears with agreement cards in Thai.
2. Consent screen includes links to Privacy Policy and Terms of Use (opens Safari).
3. User must check the acceptance checkbox before the accept button becomes enabled.
4. Tap accept, then acknowledge the simple usage guide (includes data-recording responsibility note and help link).
5. Home dashboard shows 6 modules: Medication, Blood Pressure, Feelings/Symptoms, Health Calendar, SOS, Settings.
6. Medication: add a medication item, set a reminder time, log "taken today". Local notification will fire at the scheduled time (please allow notifications when prompted).
7. Blood Pressure: add a reading (systolic/diastolic/pulse + optional note).
8. Feelings: select today's feeling and symptoms via tap choices.
9. Appointments: add a health appointment with optional reminder notification.
10. SOS: add a contact with phone number. Tap Call — a confirmation dialog appears before opening the Phone app (tel://). No auto-dial.
11. Settings: export CSV or PDF via Share Sheet (user-initiated only). View consent/guide again. Delete all data cancels pending notifications.

MEDICAL DISCLAIMER
The app repeatedly states it is NOT a medical device. It only reminds and records user-entered data. It does not diagnose, analyze, recommend medication, or provide medical advice. Disclaimers appear on: first-launch consent, home banner, every module footer, medication screen, settings, and PDF export.

PRIVACY
- Data stays on device only.
- Developer cannot access user data.
- Export requires explicit user action via Share Sheet.
- PrivacyInfo.xcprivacy declares no tracking and no collected data types sent to developer.
- Privacy Policy: https://burapatis.github.io/app/apps/pheuan-tueanya/privacy.html

PERMISSIONS
- Notifications: local reminders for medication and appointments only (no remote push).
- Phone: opens Phone app after user confirmation from SOS screen.
- No camera, location, contacts, HealthKit, or microphone access.

Please contact us if any test step is unclear. Thank you.
```

### Notes (ภาษาไทย — สำรอง)
```
แอปเพื่อนเตือนยา เป็นแอปเตือนยาและบันทึกสุขภาพในเครื่อง ไม่ต้องล็อกอิน ไม่มี backend ข้อมูลอยู่ใน SwiftData บนอุปกรณ์

วิธีทดสอบ: เปิดแอป → อ่านข้อตกลง (มีลิงก์นโยบาย/ข้อกำหนด) → ติ๊กยอมรับ → กดยินยอม → รับทราบวิธีใช้ → ทดสอบเพิ่มยา/ความดัน/อาการ/นัดหมาย/SOS/ส่งออก CSV-PDF

แอปไม่ใช่เครื่องมือแพทย์ ไม่วินิจฉัย ไม่วิเคราะห์โรค SOS เปิดแอปโทรหลังยืนยันเท่านั้น
```

### Attachment (ไม่บังคับ)
ไม่จำเป็น — ไม่มีฟีเจอร์ที่ต้องอธิบายเพิ่มด้วยวิดีโอ

### Sign-In Required
**No** — ไม่มีบัญชีผู้ใช้

---

## 7) Version Release

| ตัวเลือก | แนะนำ |
|---------|--------|
| Release | **Manually release this version** (ปลอดภัยกว่าสำหรับรอบแรก) |
| หรือ | Automatically release after approval |

---

## 8) Export Compliance (การเข้ารหัส)

ตอบในหน้า build หรือตอน submit:

| คำถาม | คำตอบ |
|-------|-------|
| Is your app designed to use cryptography or does it contain cryptography? | **Yes** (HTTPS มาตรฐานของ iOS) |
| Is it exempt? | **Yes** — ใช้ encryption มาตรฐานของ Apple เท่านั้น (ไม่มี encryption เอง) |
| Uses proprietary encryption? | **No** |

หรือเลือก: **App uses standard encryption only** / qualifies for exemption

---

## 9) Content Rights

| คำถาม | คำตอบ |
|-------|-------|
| Third-party content? | **No** (ไอคอนและ UI เป็นของโปรเจกต์) |
| Rights to all content? | **Yes** |

---

## 10) Screenshots (บังคับ)

### ขนาดที่ ASC รับ (iPhone 6.7")
- **1290 × 2796 px** (portrait)

### ไฟล์พร้อมใช้
โฟลเดอร์: `fastlane/screenshots/asc-1290x2796/`

| ลำดับ | ไฟล์ | หน้าจอ |
|------|------|--------|
| 1 | 01_home.png | หน้าแรก |
| 2 | 02_consent.png | ข้อตกลงก่อนใช้งาน |
| 3 | 03_guide.png | วิธีใช้งาน |
| 4 | 04_blood_pressure.png | ความดัน |
| 5 | 05_feelings.png | ความรู้สึกและอาการ |
| 6 | 06_calendar.png | ปฏิทินสุขภาพ |
| 7 | 07_sos.png | SOS/ผู้ติดต่อ |

**หมายเหตุ v0.6.8:** หน้าข้อตกลงและวิธีใช้งานเปลี่ยนแปลง — แนะนำถ่าย screenshot ใหม่ (`02_consent.png`, `03_guide.png`) จาก Simulator iPhone 17 Pro Max ด้วย ⌘+S ก่อนส่ง App Store

---

## 11) สิ่งที่แอปทำ / ไม่ทำ (อ้างอิงโค้ด)

### แอปทำ
- เตือนกินยาและนัดหมายด้วย **การแจ้งเตือนในเครื่อง**
- บันทึกยา ความดัน อาการ นัดหมาย ผู้ติดต่อ SOS
- ส่งออก CSV (6 ไฟล์) และ PDF สรุป 30 วัน ผ่าน Share Sheet
- แสดงข้อตกลงและวิธีใช้ตอนเปิดครั้งแรก (พร้อมลิงก์นโยบาย/ข้อกำหนด/ความช่วยเหลือ)
- ต้องติ๊กยอมรับข้อตกลงก่อนเข้าใช้งาน
- ล้างข้อมูลทั้งหมดและยกเลิกแจ้งเตือนที่ค้าง

### แอปไม่ทำ
- ไม่วินิจฉัย ไม่วิเคราะห์โรค ไม่แนะนำยา
- ไม่มี backend / cloud sync / login
- ไม่ใช้ HealthKit / Contacts / Camera / Location
- ไม่โทรอัตโนมัติ (SOS ต้องยืนยันก่อน)
- ไม่ส่งข้อมูลให้ผู้พัฒนา
- ไม่มีโฆษณา / tracking / analytics

---

## 12) Checklist ก่อนกด Submit for Review

### ใน App Store Connect
- [ ] เลือก build **0.6.8 (70)** ในหน้าเวอร์ชัน
- [ ] กรอก Description, Subtitle, Keywords, Support URL, Copyright
- [ ] อัปโหลด Screenshots 1290×2796 ครบอย่างน้อย 3 รูป (แนะนำ 7 รูป — อัปเดต consent/guide ถ้าเป็นไปได้)
- [ ] ตอบ **App Privacy** ให้ครบ
- [ ] ตอบ **Age Rating** ให้ครบ
- [ ] กรอก **App Review Information** + Notes
- [ ] ตั้ง **Pricing** = Free
- [ ] ตรวจ **Export Compliance**

### ทดสอบบนเครื่องจริง (แนะนำก่อน submit)
- [ ] เปิดครั้งแรกเห็นข้อตกลง (ลิงก์นโยบาย/ข้อกำหนด + ช่องติ๊กยอมรับ) + วิธีใช้
- [ ] ปุ่มยอมรับกดไม่ได้จนกว่าจะติ๊ก checkbox
- [ ] แจ้งเตือนยา/นัดหมายทำงาน
- [ ] SOS เปิดแอปโทรหลังยืนยัน
- [ ] ส่งออก CSV/PDF ผ่าน Share Sheet
- [ ] ล้างข้อมูลแล้วข้อมูลหาย + ไม่มีแจ้งเตือนเก่า

### หลัง Submit
- [ ] ติดตามสถานะใน App Store Connect → App Review
- [ ] ถ้า Rejected อ่าน Resolution Center และตอบตามที่ Apple ระบุ

---

## 13) ข้อความ Disclaimer ในแอป (อ้างอิงจากโค้ด — ไม่ต้องกรอกใน ASC แต่ reviewer จะเห็น)

| ตำแหน่ง | ข้อความ |
|---------|---------|
| ข้อตกลงก่อนใช้ | ไม่ใช่เครื่องมือแพทย์ — ช่วยจำและบันทึกเท่านั้น ไม่วิเคราะห์ วินิจฉัย หรือให้คำปรึกษาทางการแพทย์ |
| ข้อตกลงก่อนใช้ | ลิงก์นโยบายความเป็นส่วนตัวและข้อกำหนดการใช้งาน |
| ข้อตกลงก่อนใช้ | หากไม่ยอมรับ ขอให้ถอนการติดตั้งแอพออกจากเครื่องทันที |
| วิธีใช้งาน | ผู้บันทึกข้อมูล/ผู้ใช้ต้องรับผิดชอบการบันทึกข้อมูลทั้งหมดด้วยตนเอง |
| หน้าแรก | แอพแสดงข้อมูลและเตือนตามบันทึกเท่านั้น ไม่ใช่การวินิจฉัยโรค |
| ทุกโมดูล | แอปนี้ไม่ใช่เครื่องมือแพทย์ ข้อมูลแสดงตามที่ผู้ใช้บันทึกไว้เท่านั้น |
| หน้ายา | แอปช่วยเตือนและบันทึกเท่านั้น ไม่แนะนำยาและไม่ปรับขนาดยาแทนแพทย์ |
| PDF export | รายงานนี้สร้างจากข้อมูลที่ผู้ใช้บันทึกไว้เอง ไม่ใช่การวินิจฉัยหรือคำแนะนำทางการแพทย์ |

---

*เอกสารนี้จัดทำสำหรับ PhueanTuenYa iOS v0.6.8 — อัปเดตเมื่อมีการเปลี่ยนฟีเจอร์หรือนโยบายความเป็นส่วนตัว*
