# PhueanTuenYa iOS v0.2.0 — SRS Traceability

## เป้าหมายรุ่น
- ปรับ UI ให้สวยงามและเป็นระบบตามภาพตัวอย่างที่ผู้ใช้อัปโหลด
- ใช้ shared in-memory state เพื่อให้ข้อมูลที่บันทึกในหน้ารองสะท้อนกลับมายังหน้าแรกทันที
- แก้วันที่/เวลาไม่ให้อยู่คนละบรรทัดแบบไม่เป็นระเบียบ โดยใช้ RecordCard meta line เดียว
- ยังไม่ใช่ฐานข้อมูลถาวร รุ่นนี้ยังเป็น prototype

## Mapping กับ SRS
- Home Dashboard: มีวันที่, progress การกินยา, เมนู 6 หมวดแบบ grid 2x3, sticky disclaimer
- Medication: แยกสถานะกินยาและเพิ่มยา, มีรายการยา, มีประวัติวันนี้, ปุ่มใหญ่
- Blood Pressure: ใช้ปุ่ม +/− ขนาดใหญ่แทน keyboard มือถือ
- Symptom: ใช้ปุ่ม emoji 4 ระดับ และแจ้งเตือนเมื่อเลือกเจ็บปวดรุนแรง
- Health Calendar: ใช้ Timeline/List View ไม่ใช้ month grid
- SOS: แสดง contact card ใหญ่ และ alert ก่อนเปิดโทรศัพท์
- Settings/Export: export เกิดจากผู้ใช้กดเองเท่านั้น และมีคำเตือน
- Privacy: ไม่มี backend, ไม่มี login, ไม่มี internet permission เพิ่ม

## ยังต้องทำในรุ่นถัดไป
- First Launch Consent จริง
- SwiftData/Core Data persistence
- Edit/Delete จริงทุก record
- Export PDF/CSV จริง
- Notification schedule จริงจากรายการยาและปฏิทินสุขภาพ
