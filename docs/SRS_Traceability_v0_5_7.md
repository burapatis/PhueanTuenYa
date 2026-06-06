# เพื่อนเตือนยา iOS v0.5.7 — Real User Test Pack & Final Checklist

## เป้าหมาย
เพิ่มชุดเตรียมทดสอบผู้ใช้จริงในหน้า Settings เพื่อให้ผู้พัฒนาใช้ตรวจความพร้อมก่อนนำแอปไปทดลองกับผู้สูงอายุ/ผู้ดูแลกลุ่มเล็ก 5–10 คน

## สิ่งที่เพิ่ม
- Release Readiness Card อัปเดตเป็น v0.5.7
- ชุดทดสอบผู้ใช้จริง 5–10 คน
- แบบจด Feedback ระหว่างทดสอบ
- Final Checklist ก่อนส่งให้ทดสอบ

## หลัก SRS ที่ตรวจ
- Offline-first / local storage
- ไม่มี login / ไม่มี backend
- ผู้ใช้ควบคุมข้อมูลเอง
- First Launch Consent
- ไม่ใช่เครื่องมือแพทย์
- ผู้ใช้เป็นผู้กดส่งออกข้อมูลเอง
- UI เหมาะกับผู้สูงอายุ: อ่านง่าย ปุ่มใหญ่ ลดการพิมพ์

## Checklist ทดสอบ
- Run บน Simulator ได้
- Run บน iPhone จริงได้
- Settings แสดงชุด Real User Test Pack
- Settings แสดง Final Checklist
- ฟังก์ชันหลักจาก v0.5.6 ยังทำงานครบ
