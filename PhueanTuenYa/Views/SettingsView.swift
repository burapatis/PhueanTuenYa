import SwiftUI
import SwiftData
import UserNotifications
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var medications: [MedicationItem]
    @Query private var logs: [MedicationLogItem]
    @Query private var bp: [BloodPressureItem]
    @Query private var feelings: [FeelingItem]
    @Query private var appointments: [AppointmentItem]
    @Query private var contacts: [SOSContactItem]
    @State private var result = "ยังไม่ได้ดำเนินการ"
    @State private var showClearConfirm = false
    @State private var exportURL: URL?
    @State private var exportFileName = ""
    @State private var settingsScrollTarget = "settingsResult"
    @State private var showConsentSheet = false
    @State private var showUsageGuideSheet = false

    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                Color.appSoftBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            HeaderView(title: "⚙️ ตั้งค่า", subtitle: "ความเป็นส่วนตัว ส่งออก และจัดการข้อมูล")
                            Button { dismiss() } label: {
                                Image(systemName: "house.fill")
                                    .font(.title3.weight(.heavy))
                                    .foregroundStyle(Color.appBlue)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                        }

                        AppCard(tint: .settingsTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "ข้อมูลอยู่ในเครื่องนี้")
                                Text("ไม่มี backend ไม่มีสมัครสมาชิก ผู้พัฒนาแอพฯ ไม่สามารถเข้าถึงข้อมูลที่ผู้ใช้บันทึกได้")
                                    .font(.headline)
                                    .foregroundStyle(Color.appSubtext)
                            }
                        }

                        AppCard(tint: .settingsTint) {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionTitle(text: "ข้อตกลงและวิธีใช้งาน")
                                Text("หน้าข้อตกลงและวิธีใช้งานจะแสดงเฉพาะครั้งแรก ผู้ใช้สามารถกดดูซ้ำได้ที่นี่")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                PrimaryActionButton(title: "📋 ดูข้อตกลงการใช้งานอีกครั้ง", color: .appBlue) {
                                    showConsentSheet = true
                                }
                                PrimaryActionButton(title: "📖 ดูวิธีใช้งานอย่างง่ายอีกครั้ง", color: .appGreen) {
                                    showUsageGuideSheet = true
                                }
                            }
                        }

                        AppCard(tint: .calendarTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "ความพร้อมก่อนทดสอบจริง")
                                Text("เวอร์ชัน v0.6.6 • พร้อมตรวจ Build Settings ก่อน Archive/TestFlight")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "ข้อมูลอยู่ในเครื่องด้วย SwiftData")
                                CompactCheckRow(text: "แจ้งเตือนยาและนัดหมายทำงานในเครื่อง")
                                CompactCheckRow(text: "ส่งออก CSV/PDF โดยผู้ใช้กดเอง")
                                CompactCheckRow(text: "SOS เปิดแอปโทรศัพท์หลังยืนยัน")
                            }
                        }

                        AppCard(tint: .medTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "Checklist ทดสอบบน iPhone จริง")
                                Text("ให้ทดลองเพิ่ม/แก้ไข/ลบข้อมูล ปิดแอปแล้วเปิดใหม่ ทดสอบแจ้งเตือน แชร์ไฟล์ และกด SOS ก่อนแจกให้ผู้ทดสอบ")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "เปิดครั้งแรกเห็นหน้าข้อตกลง")
                                CompactCheckRow(text: "Notification ทดสอบขึ้นจริง")
                                CompactCheckRow(text: "Share Sheet เปิดได้จากไฟล์ CSV/PDF")
                                CompactCheckRow(text: "ล้างข้อมูลทั้งหมดแล้วหน้าแรกรีเฟรช")
                            }
                        }

                        AppCard(tint: .feelingTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "ชุดทดสอบผู้ใช้จริง 5–10 คน")
                                Text("ให้ผู้สูงอายุหรือผู้ดูแลทดลองงานจริงสั้น ๆ แล้วจดจุดที่งง กดผิด หรือมองไม่เห็นผลลัพธ์")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "เพิ่มยา 1 รายการ และบันทึกกินแล้ว")
                                CompactCheckRow(text: "บันทึกความดัน 1 ครั้ง")
                                CompactCheckRow(text: "บันทึกความรู้สึกและอาการ 1 ครั้ง")
                                CompactCheckRow(text: "เพิ่มนัดหมายสุขภาพ 1 รายการ")
                                CompactCheckRow(text: "เพิ่ม SOS และตั้งเป็นผู้ติดต่อหลัก")
                                CompactCheckRow(text: "ส่งออก PDF แล้วเปิด Share Sheet")
                            }
                        }

                        AppCard(tint: .bpTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "แบบจด Feedback ระหว่างทดสอบ")
                                Text("ให้ผู้ทดสอบให้คะแนนและบอกจุดติดขัด เพื่อใช้แก้ใน v0.6.6 หรือรุ่นถัดไป")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "อ่านตัวอักษรชัดหรือไม่")
                                CompactCheckRow(text: "ปุ่มใหญ่และกดง่ายหรือไม่")
                                CompactCheckRow(text: "เห็นผลหลังบันทึกหรือแก้ไขหรือไม่")
                                CompactCheckRow(text: "เข้าใจว่าไม่ใช่เครื่องมือแพทย์หรือไม่")
                                CompactCheckRow(text: "จุดใดที่อยากให้ลดขั้นตอนหรือทำให้ง่ายขึ้น")
                            }
                        }

                        AppCard(tint: .calendarTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "Final Checklist ก่อนส่งให้ทดสอบ")
                                Text("ตรวจครั้งสุดท้ายก่อนนำไปลงเครื่องจริงหรือแจกให้ผู้ทดสอบกลุ่มเล็ก")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "ข้อมูลยังอยู่หลังปิดแอป/เปิดใหม่")
                                CompactCheckRow(text: "แจ้งเตือนยาและนัดหมายทำงาน")
                                CompactCheckRow(text: "แก้ไข/ลบข้อมูลได้ทุกหมวด")
                                CompactCheckRow(text: "CSV/PDF สร้างและแชร์ได้")
                                CompactCheckRow(text: "ล้างข้อมูลทั้งหมดทำงานและไม่ crash")
                            }
                        }


                        AppCard(tint: .appBlue.opacity(0.18)) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "TestFlight Readiness")
                                Text("ใช้ v0.6.6 เป็นชุดตรวจ Build Settings ก่อน Archive และอัปโหลด TestFlight")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "ตั้ง Bundle Identifier และ Signing ให้ถูกต้อง")
                                CompactCheckRow(text: "ตั้ง Version เป็น 0.6.6 และ Build Number เป็น 66 ก่อน Archive")
                                CompactCheckRow(text: "ตรวจ Privacy: ไม่มี login ไม่มี backend ไม่มี cloud sync")
                                CompactCheckRow(text: "ตรวจ Notification, SOS, Share Sheet บน iPhone จริง")
                                CompactCheckRow(text: "เตรียมข้อความเชิญผู้ทดสอบและรายการงานทดสอบ")
                            }
                        }

                        AppCard(tint: .settingsTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "Build Settings ก่อน Archive")
                                Text("ตรวจค่าใน Xcode ก่อนกด Product > Archive เพื่อส่งขึ้น TestFlight")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "Version: 0.6.6")
                                CompactCheckRow(text: "Build: 66")
                                CompactCheckRow(text: "Bundle ID: com.phueanteuanya.PhueanTuenYa หรือค่าที่ผูกกับ App Store Connect")
                                CompactCheckRow(text: "Signing: Automatic และเลือก Team ของ Apple Developer")
                                CompactCheckRow(text: "Device: Any iOS Device ก่อน Archive")
                            }
                        }

                        AppCard(tint: .calendarTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "ขั้นตอน Archive / TestFlight")
                                Text("ใช้เป็น checklist สั้น ๆ ตอนอัปโหลด build ให้ผู้ทดสอบ")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "Product > Clean Build Folder")
                                CompactCheckRow(text: "Product > Archive")
                                CompactCheckRow(text: "Distribute App > App Store Connect")
                                CompactCheckRow(text: "Upload แล้วรอประมวลผลใน App Store Connect")
                                CompactCheckRow(text: "เพิ่ม Internal/External Testers ใน TestFlight")
                            }
                        }

                        AppCard(tint: .feelingTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "ข้อความสำหรับ Beta Review")
                                Text("แอปช่วยเตือนและบันทึกข้อมูลสุขภาพในเครื่องสำหรับผู้สูงอายุ ไม่ใช่เครื่องมือแพทย์ ไม่มี backend และผู้ใช้เป็นผู้กดส่งออกข้อมูลเอง")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "ทดสอบเพิ่มยาและการแจ้งเตือน")
                                CompactCheckRow(text: "ทดสอบบันทึกความดัน/อาการ/นัดหมาย")
                                CompactCheckRow(text: "ทดสอบ SOS, Export CSV/PDF และล้างข้อมูล")
                            }
                        }

                        AppCard(tint: .settingsTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "ข้อมูลแอปสำหรับ TestFlight")
                                Text("ชื่อแอป: เพื่อนเตือนยา")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Color.appBlue)
                                Text("คำอธิบายสั้น: แอปช่วยเตือนยา บันทึกความดัน อาการ นัดหมายสุขภาพ และ SOS โดยข้อมูลอยู่ในเครื่อง")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "ต้องระบุชัดว่าไม่ใช่เครื่องมือแพทย์")
                                CompactCheckRow(text: "ต้องระบุว่าข้อมูลอยู่ในเครื่องและผู้ใช้กดส่งออกเอง")
                                CompactCheckRow(text: "ยังไม่ใช้การวิเคราะห์โรคหรือคำแนะนำแทนแพทย์")
                            }
                        }

                        AppCard(tint: .feelingTint) {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionTitle(text: "ภาพหน้าจอที่ควรถ่าย")
                                Text("ใช้สำหรับ TestFlight notes หรือเตรียม App Store ภายหลัง")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                CompactCheckRow(text: "หน้าแรก Dashboard")
                                CompactCheckRow(text: "หน้าบันทึกยาและเวลาเตือน")
                                CompactCheckRow(text: "หน้าความดัน")
                                CompactCheckRow(text: "หน้าความรู้สึกและอาการ")
                                CompactCheckRow(text: "หน้าปฏิทินสุขภาพ")
                                CompactCheckRow(text: "หน้า Settings / Export / Privacy")
                            }
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionTitle(text: "ส่งออกข้อมูลด้วยตนเอง")
                                Text("ผู้ใช้เป็นผู้กดส่งออกเองเท่านั้น ข้อมูลจะถูกสร้างเป็นไฟล์ในเครื่องก่อนแชร์")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                PrimaryActionButton(title: "📄 PDF สรุปสุขภาพ 30 วัน", color: .appBlue) { exportPDFSummary() }
                                PrimaryActionButton(title: "💊 CSV ข้อมูลยา", color: .appBlue) { exportCSV(.medications) }
                                PrimaryActionButton(title: "📝 CSV ประวัติกินยา", color: .appBlue) { exportCSV(.medicationLogs) }
                                PrimaryActionButton(title: "🩺 CSV ความดัน", color: .appBlue) { exportCSV(.bloodPressure) }
                                PrimaryActionButton(title: "🙂 CSV ความรู้สึกและอาการ", color: .appBlue) { exportCSV(.feelings) }
                                PrimaryActionButton(title: "📅 CSV ปฏิทินสุขภาพ", color: .appBlue) { exportCSV(.appointments) }
                                PrimaryActionButton(title: "🆘 CSV SOS/ผู้ติดต่อ", color: .appBlue) { exportCSV(.contacts) }
                                Text("ก่อนส่งออก: ท่านกำลังนำข้อมูลสุขภาพออกจากเครื่องด้วยตนเอง หากส่งต่อผ่านแอปอื่น ข้อมูลจะอยู่นอกการปกป้องของแอปนี้")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color.appRed)
                                if let exportURL {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 10) {
                                            Image(systemName: "doc.fill")
                                                .foregroundStyle(Color.appGreen)
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text("ไฟล์พร้อมแชร์")
                                                    .font(.headline.weight(.heavy))
                                                Text(exportFileName)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(Color.appSubtext)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.75)
                                            }
                                            Spacer()
                                        }
                                        ShareLink(item: exportURL) {
                                            HStack {
                                                Image(systemName: "square.and.arrow.up.fill")
                                                Text("แชร์ไฟล์")
                                            }
                                            .font(.headline.weight(.heavy))
                                            .padding(14)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.appGreen)
                                            .foregroundStyle(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.appGreen.opacity(0.10))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .id("exportShare")
                                }
                            }
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionTitle(text: "การแจ้งเตือนยา")
                                Text("ตั้งแจ้งเตือนจากรายการยาที่บันทึกไว้ในเครื่องเท่านั้น หากยังไม่ได้อนุญาต ระบบจะขออนุญาตแจ้งเตือนก่อน")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                PrimaryActionButton(title: "🔔 ทดสอบการแจ้งเตือน", color: .appOrange) { testNotification() }
                                PrimaryActionButton(title: "💊 ตรวจและตั้งเตือนยาใหม่", color: .appGreen) { rescheduleMedicationNotifications() }
                                PrimaryActionButton(title: "🧹 ล้างแจ้งเตือนยาที่ตั้งไว้", color: .appGray) { cancelMedicationNotifications() }
                            }
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionTitle(text: "การแจ้งเตือนนัดหมายสุขภาพ")
                                Text("ตั้งแจ้งเตือนจากปฏิทินสุขภาพที่ผู้ใช้บันทึกไว้เองเท่านั้น")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                                PrimaryActionButton(title: "📅 ตรวจและตั้งเตือนนัดหมายใหม่", color: .appGreen) { rescheduleAppointmentNotifications() }
                                PrimaryActionButton(title: "🧹 ล้างแจ้งเตือนนัดหมาย", color: .appGray) { cancelAppointmentNotifications() }
                            }
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionTitle(text: "ผลล่าสุด")
                                Text(result)
                                    .font(.headline.weight(.semibold))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .id("settingsResult")

                        PrimaryActionButton(title: "ล้างข้อมูลทั้งหมด", color: .appRed) { showClearConfirm = true }

                        Text("⚠️ แอปนี้ไม่ใช่เครื่องมือแพทย์ ข้อมูลแสดงตามที่ผู้ใช้บันทึกไว้เท่านั้น")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.appSubtext)
                            .padding(.bottom, 20)
                    }
                    .padding(16)
                }
            }
            .navigationBarBackButtonHidden(false)
            .onChange(of: settingsScrollTarget) { _, target in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(target, anchor: .center)
                    }
                }
            }
            .onChange(of: result) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(settingsScrollTarget, anchor: .center)
                    }
                }
            }
        }
        .alert("ยืนยันล้างข้อมูลทั้งหมด", isPresented: $showClearConfirm) {
            Button("ล้างข้อมูล", role: .destructive) { clearAll() }
            Button("ยกเลิก", role: .cancel) { }
        } message: {
            Text("ข้อมูลที่บันทึกไว้ในเครื่องจะถูกลบทั้งหมด")
        }
        .sheet(isPresented: $showConsentSheet) {
            FirstLaunchConsentView {
                showConsentSheet = false
            }
        }
        .sheet(isPresented: $showUsageGuideSheet) {
            SimpleUsageGuideView {
                showUsageGuideSheet = false
            }
        }
    }
    private enum ExportKind {
        case medications, medicationLogs, bloodPressure, feelings, appointments, contacts

        var fileName: String {
            switch self {
            case .medications: return "phuean_tuenya_medications.csv"
            case .medicationLogs: return "phuean_tuenya_medication_logs.csv"
            case .bloodPressure: return "phuean_tuenya_blood_pressure.csv"
            case .feelings: return "phuean_tuenya_feelings_symptoms.csv"
            case .appointments: return "phuean_tuenya_appointments.csv"
            case .contacts: return "phuean_tuenya_sos_contacts.csv"
            }
        }

        var thaiName: String {
            switch self {
            case .medications: return "ข้อมูลยา"
            case .medicationLogs: return "ประวัติกินยา"
            case .bloodPressure: return "ความดัน"
            case .feelings: return "ความรู้สึกและอาการ"
            case .appointments: return "ปฏิทินสุขภาพ"
            case .contacts: return "SOS/ผู้ติดต่อ"
            }
        }
    }

    private func exportCSV(_ kind: ExportKind) {
        let csv: String
        switch kind {
        case .medications:
            csv = ExportFormatting.makeCSV(headers: ["ชื่อยา", "รหัสรายการยา", "รูปแบบ", "ปริมาณ", "วิธีใช้", "เวลาเตือน", "สถานะแจ้งเตือน", "วันที่สร้าง", "แก้ไขล่าสุด"], rows: medications.map { [
                $0.name, $0.localID?.uuidString ?? "", $0.form, $0.dosage, $0.instruction, $0.timeText, $0.notificationIdentifier == nil ? "ยังไม่ได้ตั้งแจ้งเตือน" : "ตั้งแจ้งเตือนแล้ว", shortDateTime($0.createdAt), shortDateTime($0.updatedAt)
            ]})
        case .medicationLogs:
            csv = ExportFormatting.makeCSV(headers: ["ชื่อยา", "รหัสรายการยา", "สถานะ", "วันที่เวลา"], rows: logs.map { [$0.medicationName, $0.medicationLocalID?.uuidString ?? "", $0.status, shortDateTime($0.loggedAt)] })
        case .bloodPressure:
            csv = ExportFormatting.makeCSV(headers: ["SYS", "DIA", "ชีพจร", "วันที่เวลา", "หมายเหตุ"], rows: bp.map { [String($0.systolic), String($0.diastolic), String($0.pulse), shortDateTime($0.measuredAt), $0.note] })
        case .feelings:
            csv = ExportFormatting.makeCSV(headers: ["ความรู้สึก", "อาการที่บันทึก", "วันที่เวลา"], rows: feelings.map { [$0.feeling, $0.symptom, shortDateTime($0.recordedAt)] })
        case .appointments:
            csv = ExportFormatting.makeCSV(headers: ["ประเภท", "สถานที่", "วันเวลา", "การเตือน", "สถานะแจ้งเตือน"], rows: appointments.map { [$0.type, $0.place, thaiFullDateTime($0.dateTime), $0.reminder, $0.notificationStatusText] })
        case .contacts:
            csv = ExportFormatting.makeCSV(headers: ["ชื่อ", "ความสัมพันธ์", "เบอร์โทร", "ผู้ติดต่อหลัก"], rows: contacts.map { [$0.name, $0.relationship, $0.phone, $0.isPrimary ? "ใช่" : "ไม่ใช่"] })
        }
        writeExportFile(fileName: kind.fileName, content: csv, kindName: kind.thaiName)
    }

    private func exportPDFSummary() {
        let fileName = "phuean_tuenya_30_day_summary.pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let cutoff = last30DaysStart()
        let recentMeds = medications
        let recentLogs = logs.filter { isWithinLast30Days($0.loggedAt) }
        let recentBP = bp.filter { isWithinLast30Days($0.measuredAt) }
        let recentFeelings = feelings.filter { isWithinLast30Days($0.recordedAt) }
        let recentAppointments = appointments.filter { isWithinLast30Days($0.dateTime) }
        let primaryContact = contacts.first(where: { $0.isPrimary }) ?? contacts.first

        do {
            try renderer.writePDF(to: url) { context in
                let margin: CGFloat = 36
                let contentWidth: CGFloat = pageRect.width - (margin * 2)
                var y: CGFloat = margin

                let titleFont = UIFont.boldSystemFont(ofSize: 24)
                let sectionFont = UIFont.boldSystemFont(ofSize: 18)
                let subheadFont = UIFont.boldSystemFont(ofSize: 14)
                let bodyFont = UIFont.systemFont(ofSize: 13)
                let smallFont = UIFont.systemFont(ofSize: 11)
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 3

                func attrs(_ font: UIFont, color: UIColor = .black) -> [NSAttributedString.Key: Any] {
                    [.font: font, .foregroundColor: color, .paragraphStyle: paragraph]
                }

                func beginPage() {
                    context.beginPage()
                    y = margin
                }

                func ensureSpace(_ needed: CGFloat) {
                    if y + needed > pageRect.height - margin {
                        beginPage()
                    }
                }

                func drawText(_ text: String, font: UIFont = bodyFont, color: UIColor = .black, spacing: CGFloat = 8) {
                    let height = text.height(constrainedTo: contentWidth, font: font) + 6
                    ensureSpace(height + spacing)
                    text.draw(in: CGRect(x: margin, y: y, width: contentWidth, height: height), withAttributes: attrs(font, color: color))
                    y += height + spacing
                }

                func drawDivider() {
                    ensureSpace(12)
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: margin, y: y))
                    path.addLine(to: CGPoint(x: pageRect.width - margin, y: y))
                    UIColor.systemGray4.setStroke()
                    path.lineWidth = 1
                    path.stroke()
                    y += 14
                }

                func drawSection(_ title: String, rows: [String], emptyText: String = "ยังไม่มีข้อมูล") {
                    ensureSpace(68)
                    drawText(title, font: sectionFont, color: UIColor(red: 0.08, green: 0.18, blue: 0.32, alpha: 1), spacing: 4)
                    if rows.isEmpty {
                        drawText("• \(emptyText)", font: bodyFont, color: .darkGray, spacing: 8)
                    } else {
                        for row in rows {
                            drawText("• \(row)", font: bodyFont, color: .black, spacing: 4)
                        }
                    }
                    drawDivider()
                }

                beginPage()
                drawText("เพื่อนเตือนยา", font: titleFont, color: UIColor(red: 0.08, green: 0.18, blue: 0.32, alpha: 1), spacing: 2)
                drawText("รายงานสรุปสุขภาพ 30 วัน", font: sectionFont, color: .darkGray, spacing: 8)
                drawText("ช่วงข้อมูล: \(shortDateTime(cutoff)) ถึง \(shortDateTime(Date()))", font: bodyFont, color: .darkGray, spacing: 4)
                drawText("วันที่สร้างรายงาน: \(shortDateTime(Date()))", font: bodyFont, color: .darkGray, spacing: 10)

                drawText("⚠️ รายงานนี้สร้างจากข้อมูลที่ผู้ใช้บันทึกไว้เองในเครื่องเท่านั้น ไม่ใช่การวิเคราะห์ วินิจฉัย หรือคำแนะนำทางการแพทย์", font: subheadFont, color: .black, spacing: 8)
                drawText("ก่อนส่งต่อไฟล์นี้ ผู้ใช้ควรตรวจสอบข้อมูลและเป็นผู้ตัดสินใจส่งออกด้วยตนเอง ข้อมูลที่ส่งออกไปยังแอปภายนอกจะอยู่นอกการคุ้มครองของเครื่องนี้", font: smallFont, color: .darkGray, spacing: 12)
                drawDivider()

                drawSection("1) สรุปภาพรวม", rows: [
                    "รายการยาปัจจุบัน: \(medications.count) รายการ",
                    "ประวัติกินยา (30 วัน): \(recentLogs.count) รายการ",
                    "บันทึกความดัน (30 วัน): \(recentBP.count) รายการ",
                    "บันทึกความรู้สึกและอาการ (30 วัน): \(recentFeelings.count) รายการ",
                    "นัดหมายสุขภาพ (30 วัน): \(recentAppointments.count) รายการ",
                    "ผู้ติดต่อ SOS: \(contacts.count) รายการ",
                    "ผู้ติดต่อหลัก: \(primaryContact?.name ?? "ยังไม่มี")"
                ])

                drawSection("2) รายการยา", rows: recentMeds.map { med in
                    "\(med.name) • \(med.dosage) • \(med.instruction) • เวลาเตือน \(med.timeText)"
                }, emptyText: "ยังไม่มีรายการยา")

                drawSection("3) ประวัติกินยาล่าสุด", rows: recentLogs.map { log in
                    "\(log.medicationName) • \(log.status) • \(shortDateTime(log.loggedAt))"
                }, emptyText: "ยังไม่มีประวัติกินยา")

                drawSection("4) ความดันล่าสุด", rows: recentBP.map { item in
                    "\(item.systolic)/\(item.diastolic) mmHg • ชีพจร \(item.pulse) • \(shortDateTime(item.measuredAt))\(item.note.isEmpty ? "" : " • หมายเหตุ: \(item.note)")"
                }, emptyText: "ยังไม่มีบันทึกความดัน")

                drawSection("5) ความรู้สึกและอาการล่าสุด", rows: recentFeelings.map { item in
                    "ความรู้สึก: \(item.feeling) • อาการที่บันทึก: \(item.symptom) • \(shortDateTime(item.recordedAt))"
                }, emptyText: "ยังไม่มีบันทึกความรู้สึกและอาการ")

                drawSection("6) นัดหมายสุขภาพ", rows: recentAppointments.map { item in
                    "\(item.type) • \(item.place) • \(thaiFullDateTime(item.dateTime)) • \(item.reminder)"
                }, emptyText: "ยังไม่มีนัดหมายสุขภาพ")

                drawSection("7) SOS/ผู้ติดต่อ", rows: contacts.prefix(6).map { item in
                    "\(item.isPrimary ? "⭐ " : "")\(item.name) • \(item.relationship) • \(item.phone)"
                }, emptyText: "ยังไม่มีผู้ติดต่อ")

                drawText("หมายเหตุ: รายงานนี้เป็นเพียงเอกสารช่วยสรุปข้อมูลที่ผู้ใช้บันทึกไว้ เพื่อใช้พูดคุยกับแพทย์หรือผู้ดูแล ไม่ใช่เอกสารรับรองทางการแพทย์", font: smallFont, color: .darkGray, spacing: 0)
            }
            exportURL = url
            exportFileName = fileName
            settingsScrollTarget = "exportShare"
            result = "สร้าง PDF สรุปสุขภาพ 30 วันแล้ว"
        } catch {
            result = "สร้าง PDF ไม่สำเร็จ: \(error.localizedDescription)"
        }
    }

    private func writeExportFile(fileName: String, content: String, kindName: String) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
            exportFileName = fileName
            settingsScrollTarget = "exportShare"
            result = "สร้างไฟล์ CSV \(kindName) แล้ว กดปุ่มแชร์ไฟล์ด้านบนเพื่อส่งออกด้วยตนเอง"
        } catch {
            result = "สร้างไฟล์ส่งออกไม่สำเร็จ: \(error.localizedDescription)"
        }
    }

    private func clearAll() {
        MedicationNotificationService.cancelMedicationReminders(for: medications)
        AppointmentNotificationService.cancelAppointmentReminders(for: appointments)
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        resetAppBadge()

        medications.forEach { context.delete($0) }
        logs.forEach { context.delete($0) }
        bp.forEach { context.delete($0) }
        feelings.forEach { context.delete($0) }
        appointments.forEach { context.delete($0) }
        contacts.forEach { context.delete($0) }
        saveContext(context)
        settingsScrollTarget = "settingsResult"
        result = "ล้างข้อมูลทั้งหมดแล้ว และยกเลิกการแจ้งเตือนที่ตั้งไว้ทั้งหมด"
    }
    private func testNotification() {
        MedicationNotificationService.scheduleTestNotification { message in
            settingsScrollTarget = "settingsResult"
            result = message
        }
    }

    private func rescheduleMedicationNotifications() {
        MedicationNotificationService.rescheduleAllMedicationReminders(for: medications) { message in
            saveContext(context)
            settingsScrollTarget = "settingsResult"
            result = message
        }
    }

    private func cancelMedicationNotifications() {
        MedicationNotificationService.cancelMedicationReminders(for: medications)
        medications.forEach { $0.notificationIdentifier = nil }
        saveContext(context)
        settingsScrollTarget = "settingsResult"
        result = "ล้างแจ้งเตือนยาที่ตั้งไว้แล้ว หากต้องการตั้งใหม่ ให้กด ตรวจและตั้งเตือนยาใหม่"
    }

    private func rescheduleAppointmentNotifications() {
        AppointmentNotificationService.rescheduleAllAppointmentReminders(for: appointments) { message in
            saveContext(context)
            settingsScrollTarget = "settingsResult"
            result = message
        }
    }

    private func cancelAppointmentNotifications() {
        AppointmentNotificationService.cancelAppointmentReminders(for: appointments)
        appointments.forEach { $0.notificationIdentifier = nil }
        saveContext(context)
        settingsScrollTarget = "settingsResult"
        result = "ล้างแจ้งเตือนนัดหมายแล้ว หากต้องการตั้งใหม่ ให้กด ตรวจและตั้งเตือนนัดหมายใหม่"
    }
}
