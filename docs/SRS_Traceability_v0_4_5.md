# SRS Traceability — PhueanTuenYa iOS v0.4.5

## Version
เพื่อนเตือนยา iOS v0.4.5 — Export CSV/PDF Foundation

## SRS Alignment
- Manual User-Initiated Export: ผู้ใช้ต้องกดส่งออกด้วยตนเองเท่านั้น
- Offline-first / Local-first: สร้างไฟล์จากข้อมูลในเครื่อง ไม่มี backend ไม่มี cloud sync
- Privacy Warning: แจ้งเตือนก่อนส่งออกว่าข้อมูลจะออกจากการปกป้องของแอปเมื่อผู้ใช้แชร์ต่อเอง
- User Ownership: เพิ่ม/ดู/แก้ไข/ลบ/ล้างข้อมูล และส่งออกข้อมูลได้ด้วยตนเอง

## Implemented
- CSV ข้อมูลยา
- CSV ประวัติกินยา
- CSV ความดัน
- CSV ความรู้สึกและอาการ
- CSV ปฏิทินสุขภาพ
- CSV SOS/ผู้ติดต่อ
- PDF สรุปสุขภาพ 30 วันขั้นพื้นฐาน
- ShareLink สำหรับแชร์ไฟล์ที่ผู้ใช้สร้างเอง

## Not Yet Implemented
- PDF รายงานแบบจัดรูปเล่มสมบูรณ์
- กรองช่วงวันที่แบบเลือกเอง
- ส่งออกแบบรวม ZIP
