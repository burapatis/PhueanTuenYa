# SRS Traceability v0.3.4

## Medication Reminder Time Picker Fix

- ปรับช่องเวลาเตือนในหน้าบันทึกรายการยาใหม่ให้ใช้ DatePicker แบบเลื่อนเลือกเวลาได้จริง
- ลดความสับสนจากตัวเลือกเวลาคงที่
- ยังคง Choice-first Input ในช่องอื่น ๆ
- ยังคง SwiftData local persistence และเรียก saveContext หลังบันทึกรายการยา

## SRS Alignment

- เหมาะกับผู้สูงอายุ: ลดการพิมพ์ ใช้ตัวเลือกแบบ native iOS ที่คุ้นเคย
- Offline-first: ไม่มี backend / ไม่มี login / ไม่มี cloud sync
- ไม่ใช่เครื่องมือแพทย์: ระบบช่วยเตือนตามข้อมูลที่ผู้ใช้บันทึกเองเท่านั้น
