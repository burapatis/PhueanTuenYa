import SwiftUI
import SwiftData

// MARK: - Home

struct HomeView: View {
    @Query(sort: \MedicationItem.updatedAt, order: .reverse) private var medications: [MedicationItem]
    @Query(sort: \MedicationLogItem.loggedAt, order: .reverse) private var medicationLogs: [MedicationLogItem]
    @Query(sort: \BloodPressureItem.measuredAt, order: .reverse) private var bpRecords: [BloodPressureItem]
    @Query(sort: \FeelingItem.recordedAt, order: .reverse) private var feelingRecords: [FeelingItem]
    @Query(sort: \AppointmentItem.dateTime, order: .forward) private var appointments: [AppointmentItem]
    @Query(sort: \SOSContactItem.updatedAt, order: .reverse) private var contacts: [SOSContactItem]

    @State private var showTodayMedicationLogs = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.appSoftBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Image(systemName: "house.fill")
                                    .font(.title.weight(.heavy))
                                    .foregroundStyle(Color.appBlue)
                                Text("เพื่อนเตือนยา")
                                    .font(.system(size: 32, weight: .heavy))
                            }
                            Text(todayText())
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appSubtext)
                        }
                        .padding(.top, 4)

                        medicationProgressCard

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                            SummaryCard(icon: "💊", title: "ยา", value: medicationValue, detail: medicationDetail, tint: .medTint, destination: MedicationView())
                            SummaryCard(icon: "🩺", title: "ความดัน", value: bpRecords.first?.valueText ?? "ยังไม่มี", detail: bpRecords.first?.detailText ?? "แตะเพื่อบันทึก", tint: .bpTint, destination: BloodPressureView())
                            SummaryCard(icon: "🙂", title: "ความรู้สึก", value: feelingRecords.first?.feeling ?? "ยังไม่มี", detail: feelingRecords.first?.symptom ?? "แตะเพื่อบันทึก", tint: .feelingTint, destination: FeelingView())
                            SummaryCard(icon: "📅", title: "นัดหมาย", value: appointments.first?.type ?? "ยังไม่มี", detail: appointmentDetail, tint: .calendarTint, destination: AppointmentView())
                            SummaryCard(icon: "🆘", title: "SOS", value: primaryContact?.name ?? "ยังไม่มี", detail: primaryContact.map { "\($0.relationship) • \($0.phone)" } ?? "แตะเพื่อตั้งค่า", tint: .sosTint, destination: SOSView())
                            SummaryCard(icon: "⚙️", title: "ตั้งค่า", value: "ความเป็นส่วนตัว", detail: "ส่งออก/แจ้งเตือน/ล้างข้อมูล", tint: .settingsTint, destination: SettingsView())
                        }

                        Spacer(minLength: 70)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                }

                disclaimerBanner
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showTodayMedicationLogs) {
                TodayMedicationLogsSheet(logs: todayMedicationLogs, medicationCount: medications.count)
            }
        }
    }

    private var todayMedicationLogs: [MedicationLogItem] {
        medicationLogs.filter { Calendar.current.isDateInToday($0.loggedAt) }
    }

    private var medicationValue: String {
        let taken = todayMedicationLogs.filter { $0.status == "กินแล้ว" }.count
        let total = medications.count
        return "\(taken)/\(total) รายการ"
    }

    private var medicationDetail: String {
        if let log = medicationLogs.first { return "ล่าสุด: \(log.summary)" }
        if let med = medications.first { return "รายการล่าสุด: \(med.name) \(med.timeText)" }
        return "แตะเพื่อเพิ่มรายการยา"
    }

    private var appointmentDetail: String {
        guard let appointment = appointments.first else { return "แตะเพื่อเพิ่มนัดหมาย" }
        return "\(appointment.place) • \(shortDateTime(appointment.dateTime))"
    }

    private var primaryContact: SOSContactItem? {
        contacts.first(where: { $0.isPrimary }) ?? contacts.first
    }

    private var medicationProgressCard: some View {
        Button {
            showTodayMedicationLogs = true
        } label: {
            AppCard(tint: Color.white) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ความคืบหน้าการกินยาวันนี้")
                                .font(.headline.weight(.heavy))
                            Text("แตะการ์ดนี้เพื่อดูรายการที่บันทึกไว้วันนี้")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appSubtext)
                        }
                        Spacer()
                        Image(systemName: "list.bullet.rectangle.fill")
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(Color.appBlue)
                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(Color.appSubtext)
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text("กินแล้ว")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.appSubtext)
                        Text("\(todayMedicationLogs.filter { $0.status == "กินแล้ว" }.count)")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Color.appGreen)
                        Text("ครั้ง")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.appSubtext)
                        Spacer()
                        Text("ยา \(medications.count) รายการ")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(Color.appBlue)
                    }

                    ProgressView(value: Double(todayMedicationLogs.filter { $0.status == "กินแล้ว" }.count), total: Double(max(medications.count, 1)))
                        .tint(Color.appGreen)

                    Text(todayMedicationLogs.isEmpty ? "ยังไม่มีบันทึกกินยาวันนี้" : "บันทึกวันนี้ทั้งหมด \(todayMedicationLogs.count) ครั้ง")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.appSubtext)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var disclaimerBanner: some View {
        Text("⚠️ แอพแสดงข้อมูลและเตือนตามบันทึกเท่านั้น ไม่ใช่การวินิจฉัยโรค")
            .font(.footnote.weight(.heavy))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.appNavy.opacity(0.96))
    }
}

struct TodayMedicationLogsSheet: View {
    let logs: [MedicationLogItem]
    let medicationCount: Int
    @Environment(\.dismiss) private var dismiss

    private var takenCount: Int { logs.filter { $0.status == "กินแล้ว" }.count }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appSoftBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HighlightCard(tint: Color.medTint, accent: Color.appRed) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ประวัติกินยาวันนี้")
                                    .font(.title3.weight(.heavy))
                                Text("กินแล้ว \(takenCount) ครั้ง • บันทึกทั้งหมด \(logs.count) ครั้ง • รายการยา \(medicationCount) รายการ")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Color.appBlue)
                                Text("จำนวนครั้งที่บันทึกอาจมากกว่าจำนวนยาได้ หากผู้ใช้บันทึกยาซ้ำหรือใช้ปุ่มเตือนอีกครั้ง")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                            }
                        }

                        if logs.isEmpty {
                            AppCard(tint: Color.white) {
                                Text("ยังไม่มีบันทึกกินยาวันนี้")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Color.appSubtext)
                            }
                        } else {
                            ForEach(logs) { log in
                                ListRowCard {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(log.medicationName)
                                            .font(.headline.weight(.heavy))
                                            .foregroundStyle(Color.appBlue)
                                        HStack(spacing: 8) {
                                            Text(log.status)
                                                .font(.subheadline.weight(.heavy))
                                                .foregroundStyle(log.status == "กินแล้ว" ? Color.appGreen : Color.appOrange)
                                            Text("• \(shortTime(log.loggedAt)) น.")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color.appSubtext)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("บันทึกวันนี้")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("ปิด") { dismiss() }
                        .font(.headline.weight(.bold))
                }
            }
        }
    }
}

