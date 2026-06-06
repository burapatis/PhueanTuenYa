# SRS Traceability v0.4.1

## Medication Local Notification Foreground Polish

- เพิ่ม AppDelegate + UNUserNotificationCenterDelegate เพื่อให้ notification แสดงเป็น banner/list/sound แม้แอปกำลังเปิดอยู่ด้านหน้า
- ปรับ request authorization ให้ตรวจสถานะ permission ก่อน หาก denied ให้แจ้งผู้ใช้ไปเปิด Settings
- ปรับข้อความผลลัพธ์ปุ่มทดสอบการแจ้งเตือนให้ชัดขึ้น
- ยังไม่มี backend / login / cloud sync
- ข้อมูลรายการยายังคงบันทึกด้วย SwiftData ภายในเครื่อง
