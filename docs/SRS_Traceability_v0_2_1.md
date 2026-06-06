# เพื่อนเตือนยา iOS v0.2.1 — SRS Traceability

## จุดที่ปรับตามข้อเสนอผู้ใช้
- รวมเมนูหลักเข้ากับการ์ดสรุปวันนี้แบบกดได้
- ข้อมูลที่บันทึกในหน้ารองสะท้อนกลับหน้าแรกผ่าน shared in-memory CareStore
- ปรับปุ่มความดันไม่ให้ล้นหน้าจอ โดยใช้ NumberStepperCard แบบ 2 คอลัมน์/เต็มแถว
- ปรับหน้าอาการให้ใช้คำถาม “วันนี้รู้สึกอย่างไร” และ emoji 4 ระดับ
- ตัดปุ่มกลับหน้าแรกซ้ำ เหลือปุ่มย้อนกลับบน header
- SOS ไม่ตั้งผู้ติดต่อท้ายสุดเป็นหลักอัตโนมัติ และมีปุ่ม “ตั้งหลัก”

## จุดที่ยังเป็น Mock/In-memory
- ยังไม่ใช้ SwiftData/Core Data
- ยังไม่บันทึกถาวรหลังปิดแอป
- Export ยังเป็น mock
- Notification test ใช้ local notification แบบพื้นฐาน

## SRS Alignment
- Home Dashboard: วันที่, progress ยา, 6 หมวดแบบ grid, sticky disclaimer
- Elderly-friendly UI: ฟอนต์ใหญ่, ปุ่มใหญ่, high contrast, ลดการพิมพ์
- Offline-first: ไม่มี backend/login
- Symptom emergency alert: กดอาการรุนแรงแล้วแจ้งให้ติดต่อแพทย์/1669
- Health Calendar: Timeline/List View ไม่ใช้ calendar month grid
- SOS: แจ้งเตือนก่อนเปิดแอปโทรศัพท์
