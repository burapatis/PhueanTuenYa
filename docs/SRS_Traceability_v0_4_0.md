# SRS Traceability v0.4.0 — Medication Local Notification Foundation

## สิ่งที่ทำในรุ่นนี้
- เริ่ม Local Notification สำหรับรายการยาในเครื่อง
- ตั้งแจ้งเตือนซ้ำทุกวันตามเวลา `timeText` ของรายการยา
- เพิ่มปุ่มตรวจและตั้งเตือนยาใหม่ใน Settings
- เพิ่มปุ่มล้างแจ้งเตือนยาใน Settings

## สอดคล้องกับ SRS
- Medication Alert: ระบบส่งสัญญาณเตือนตามรายการยาที่ผู้ใช้บันทึก
- Offline-first: ไม่ใช้ backend และไม่ส่งข้อมูลออกนอกเครื่อง
- User control: ผู้ใช้เพิ่ม/แก้ไข/ลบรายการยา และล้างแจ้งเตือนที่ตั้งไว้ได้
- Medical disclaimer: ยังยืนยันว่าแอปเป็นเครื่องมือช่วยจำ ไม่วิเคราะห์/วินิจฉัยโรค

## ข้อจำกัดที่ยังไม่ทำ
- ยังไม่ทำเสียงเฉพาะคลื่นความถี่ต่ำ
- ยังไม่ทำ full-screen medication alert
- ยังไม่ทำ notification action เช่น กินแล้ว/ข้าม จาก notification โดยตรง
