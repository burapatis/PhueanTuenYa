import SwiftUI
import SwiftData
import UserNotifications
import UIKit

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

// MARK: - Medication

struct MedicationView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \MedicationItem.updatedAt, order: .reverse) private var medications: [MedicationItem]
    @Query(sort: \MedicationLogItem.loggedAt, order: .reverse) private var logs: [MedicationLogItem]

    @State private var showForm = false
    @State private var editing: MedicationItem?
    @State private var name = "ยาความดัน"
    @State private var form = "เม็ด"
    @State private var dosage = "1 เม็ด"
    @State private var instruction = "หลังอาหาร"
    @State private var timeText = "08:00"
    @State private var reminderTime = makeTimeDate(hour: 8, minute: 0)
    @State private var otherName = ""
    @State private var otherForm = ""
    @State private var otherDosage = ""
    @State private var otherInstruction = ""
    @State private var selectedMedName = ""
    @State private var deleteTarget: MedicationItem?
    @State private var deleteLogTarget: MedicationLogItem?
    @State private var medicationSaveScrollToken = 0
    @State private var medicationNotice = ""

    let names = ["ยาความดัน", "ยาเบาหวาน", "ยาลดไขมัน", "ยาบำรุง", "อื่น ๆ"]
    let forms = ["เม็ด", "แคปซูล", "น้ำ", "หยอด", "ฉีด", "อื่น ๆ"]
    let dosages = ["1/4 เม็ด", "ครึ่งเม็ด", "1 เม็ด", "2 เม็ด", "1 ช้อนชา", "5 มล.", "อื่น ๆ"]
    let instructions = ["ก่อนอาหาร", "หลังอาหาร", "ก่อนนอน", "ตามแพทย์สั่ง", "อื่น ๆ"]

    var body: some View {
        ModuleScaffold(title: "💊 บันทึกยา", subtitle: "ข้อมูลจะถูกบันทึกในเครื่อง") {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 14) {
                    latestCard.id("latest")
                    medicationNoticeCard.id("medicationNotice")
                    allMedicationCard.id("medicationList")
                    medicationStatusCard
                    formCard.id("form")
                    disclaimer
                }
                .onAppear { selectedMedName = medications.first?.name ?? ""; reminderTime = dateFromTimeText(timeText) }
                .onChange(of: medications.count) { _, _ in selectedMedName = medications.first?.name ?? selectedMedName }
                 .onChange(of: showForm) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation { proxy.scrollTo("saveButton", anchor: .bottom) }
                        }
                    }
                }
                .onChange(of: medicationSaveScrollToken) { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation { proxy.scrollTo("medicationNotice", anchor: .center) }
                    }
                }
            }
        }
        .alert("ยืนยันการลบ", isPresented: .constant(deleteTarget != nil), presenting: deleteTarget) { item in
            Button("ลบ", role: .destructive) { MedicationNotificationService.cancelMedicationReminder(for: item); context.delete(item); saveContext(context); deleteTarget = nil }
            Button("ยกเลิก", role: .cancel) { deleteTarget = nil }
        } message: { item in Text("ต้องการลบ \(item.name) หรือไม่") }
        .alert("ลบประวัติ", isPresented: .constant(deleteLogTarget != nil), presenting: deleteLogTarget) { item in
            Button("ลบ", role: .destructive) { context.delete(item); saveContext(context); deleteLogTarget = nil }
            Button("ยกเลิก", role: .cancel) { deleteLogTarget = nil }
        } message: { item in Text(item.summary) }
    }

    private var latestCard: some View {
        HighlightCard(tint: .medTint, accent: .appRed) {
            VStack(alignment: .leading, spacing: 8) {
                SectionTitle(text: "ผลล่าสุด/วันนี้")
                Text(logs.first?.summary ?? medications.first?.summary ?? "ยังไม่มีข้อมูลยา")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(Color.appBlue)
                Text(logs.first.map { shortDateTime($0.loggedAt) } ?? "เพิ่มรายการยา หรือบันทึกสถานะกินยา")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appSubtext)
            }
        }
    }


    private var medicationNoticeCard: some View {
        Group {
            if !medicationNotice.isEmpty {
                HighlightCard(tint: Color(red: 0.78, green: 0.94, blue: 0.82), accent: .appGreen) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.appGreen)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ผลการตั้งเตือน")
                                .font(.headline.weight(.heavy))
                            Text(medicationNotice)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appSubtext)
                        }
                    }
                }
            }
        }
    }

    private var allMedicationCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(text: "รายการยาทั้งหมด")
                if medications.isEmpty { Text("ยังไม่มีรายการยา").foregroundStyle(Color.appSubtext) }
                ForEach(medications) { item in
                    ListRowCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name).font(.headline.weight(.heavy))
                            Text("\(item.dosage) • \(item.form) • \(item.instruction) • \(item.timeText)")
                                .font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext)
                            Text(item.notificationIdentifier == nil ? "ยังไม่ได้ตั้งแจ้งเตือน" : "ตั้งแจ้งเตือนแล้ว • เวลา \(item.timeText) น.")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(item.notificationIdentifier == nil ? Color.appOrange : Color.appGreen)
                            HStack {
                                InlineActionButton(title: "แก้ไข", systemImage: "pencil", tint: .appBlue) { beginEdit(item) }
                                InlineActionButton(title: "ลบ", systemImage: "trash", tint: .appRed) { deleteTarget = item }
                            }
                        }
                    }
                }
            }
        }
    }

    private var medicationStatusCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(text: "บันทึกสถานะกินยาวันนี้")
                ChoiceMenu(title: "เลือกรายการยา", selection: $selectedMedName, options: medications.map { $0.name }.isEmpty ? ["ยังไม่มีรายการยา"] : medications.map { $0.name })
                HStack(spacing: 8) {
                    statusButton("กินแล้ว", .appGreen)
                    statusButton("ข้าม", .appOrange)
                    statusButton("เตือนอีก 10 นาที", .appBlue)
                }
                if !logs.isEmpty {
                    Text("ประวัติกินยาวันนี้").font(.headline.weight(.heavy))
                    ForEach(logs) { log in
                        ListRowCard {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(log.summary).font(.headline.weight(.bold))
                                    Text(shortDateTime(log.loggedAt)).font(.caption.weight(.semibold)).foregroundStyle(Color.appSubtext)
                                }
                                Spacer()
                                InlineActionButton(title: "ลบ", systemImage: "trash", tint: .appRed) { deleteLogTarget = log }
                            }
                        }
                    }
                }
            }
        }
    }

    private func statusButton(_ text: String, _ color: Color) -> some View {
        Button(text) {
            guard selectedMedName != "ยังไม่มีรายการยา", !selectedMedName.isEmpty else { return }
            context.insert(MedicationLogItem(medicationName: selectedMedName, status: text))
            saveContext(context)
            medicationNotice = "บันทึกสถานะ ‘\(text)’ ของ \(selectedMedName) แล้ว"
            medicationSaveScrollToken += 1
        }
        .font(.subheadline.weight(.heavy))
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.14))
        .foregroundStyle(color)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var formCard: some View {
        AppCard(tint: Color.white) {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    withAnimation { showForm.toggle() }
                } label: {
                    FormToggleButton(title: editing == nil ? "เพิ่มรายการยาใหม่" : "แก้ไขรายการยาและการเตือน", isOpen: showForm, color: .appGreen)
                }.buttonStyle(.plain)

                if showForm {
                    if editing != nil { UnsavedEditHint() }
                    ChoiceMenu(title: "ชื่อยา", selection: $name, options: names)
                    if name == "อื่น ๆ" { OtherTextField(placeholder: "ระบุชื่อยา", text: $otherName) }
                    ChoiceMenu(title: "รูปแบบ", selection: $form, options: forms)
                    if form == "อื่น ๆ" { OtherTextField(placeholder: "ระบุรูปแบบยา", text: $otherForm) }
                    ChoiceMenu(title: "ปริมาณ", selection: $dosage, options: dosages)
                    if dosage == "อื่น ๆ" { OtherTextField(placeholder: "ระบุปริมาณยา เช่น 1/4 เม็ด หรือ 5 มล.", text: $otherDosage) }
                    ChoiceMenu(title: "วิธีใช้", selection: $instruction, options: instructions)
                    if instruction == "อื่น ๆ" { OtherTextField(placeholder: "ระบุวิธีใช้", text: $otherInstruction) }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("เวลาเตือน")
                            .font(.headline.weight(.bold))
                        DatePicker("เลือกเวลาเตือน", selection: $reminderTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.compact)
                            .font(.headline)
                            .onChange(of: reminderTime) { _, newValue in
                                timeText = timeOnlyText(newValue)
                            }
                        Text("เวลาที่เลือก: \(timeText) • ระบบจะตั้งแจ้งเตือนในเครื่องหลังบันทึก")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appSubtext)
                    }
                    .padding(12)
                    .background(Color.appSoftBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    PrimaryActionButton(title: editing == nil ? "บันทึกรายการยา" : "บันทึกการแก้ไขยา", color: .appGreen) { saveMedication() }.id("saveButton")
                }
            }
        }
    }

    private var disclaimer: some View { Text("แอปช่วยเตือนและบันทึกเท่านั้น ไม่แนะนำยาและไม่ปรับขนาดยาแทนแพทย์").font(.footnote.weight(.semibold)).foregroundStyle(Color.appSubtext) }

    private func resolved(_ selection: String, _ other: String) -> String { selection == "อื่น ๆ" && !other.isEmpty ? other : selection }

    private func beginEdit(_ item: MedicationItem) {
        editing = item
        name = names.contains(item.name) ? item.name : "อื่น ๆ"
        otherName = names.contains(item.name) ? "" : item.name
        form = forms.contains(item.form) ? item.form : "อื่น ๆ"
        otherForm = forms.contains(item.form) ? "" : item.form
        dosage = dosages.contains(item.dosage) ? item.dosage : "อื่น ๆ"
        otherDosage = dosages.contains(item.dosage) ? "" : item.dosage
        instruction = instructions.contains(item.instruction) ? item.instruction : "อื่น ๆ"
        otherInstruction = instructions.contains(item.instruction) ? "" : item.instruction
        timeText = item.timeText
        reminderTime = dateFromTimeText(item.timeText)
        showForm = true
    }

    private func saveMedication() {
        let itemName = resolved(name, otherName)
        let itemForm = resolved(form, otherForm)
        let itemDosage = resolved(dosage, otherDosage)
        let itemInstruction = resolved(instruction, otherInstruction)
        let targetItem: MedicationItem

        if let editing {
            editing.name = itemName
            editing.form = itemForm
            editing.dosage = itemDosage
            editing.instruction = itemInstruction
            editing.timeText = timeText
            editing.updatedAt = Date()
            targetItem = editing
        } else {
            let newItem = MedicationItem(name: itemName, form: itemForm, dosage: itemDosage, instruction: itemInstruction, timeText: timeText)
            context.insert(newItem)
            targetItem = newItem
        }

        selectedMedName = itemName
        saveContext(context)
        let wasEditing = editing != nil
        MedicationNotificationService.scheduleMedicationReminder(for: targetItem) { message in
            medicationNotice = wasEditing
                ? "แก้ไขยาแล้ว: \(targetItem.name) • \(targetItem.dosage) • \(targetItem.instruction) • เวลา \(targetItem.timeText) น."
                : "บันทึกยาแล้ว: \(targetItem.name) • \(targetItem.dosage) • \(targetItem.instruction) • เวลา \(targetItem.timeText) น."
            if message.contains("ยังไม่ได้อนุญาต") || message.contains("ไม่สำเร็จ") {
                medicationNotice = message
            }
            saveContext(context)
        }
        saveContext(context)
        self.editing = nil
        showForm = false
        medicationSaveScrollToken += 1
    }
}

// MARK: - Blood Pressure

struct BloodPressureView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BloodPressureItem.measuredAt, order: .reverse) private var records: [BloodPressureItem]
    @State private var showForm = false
    @State private var editing: BloodPressureItem?
    @State private var systolic = 120
    @State private var diastolic = 80
    @State private var pulse = 72
    @State private var measuredAt = Date()
    @State private var deleteTarget: BloodPressureItem?
    @State private var bpNotice = ""
    @State private var bpSaveScrollToken = 0

    var body: some View {
        ModuleScaffold(title: "🩺 ความดัน", subtitle: "บันทึกค่าตามที่ผู้ใช้วัดได้") {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 14) {
                    HighlightCard(tint: .bpTint, accent: .appBlue) {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionTitle(text: "ผลล่าสุด")
                            Text(records.first?.valueText ?? "ยังไม่มี")
                                .font(.system(size: 34, weight: .heavy))
                                .foregroundStyle(Color.appBlue)
                            Text(records.first?.detailText ?? "บันทึกค่าความดันครั้งแรก")
                                .font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext)
                        }
                    }.id("latest")
                    if !bpNotice.isEmpty {
                        AppCard(tint: Color.appGreen.opacity(0.18)) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill").font(.title2.weight(.bold)).foregroundStyle(Color.appGreen)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ผลการบันทึกความดัน").font(.headline.weight(.heavy))
                                    Text(bpNotice).font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext)
                                }
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(text: "บันทึกทั้งหมด")
                            if records.isEmpty { Text("ยังไม่มีข้อมูล").foregroundStyle(Color.appSubtext) }
                            ForEach(records) { item in
                                ListRowCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.valueText)
                                                .font(.title3.weight(.heavy))
                                                .foregroundStyle(Color.appBlue)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                            Text(item.detailText)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color.appSubtext)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        HStack(spacing: 10) {
                                            InlineActionButton(title: "แก้ไข", systemImage: "pencil", tint: .appBlue) { beginEdit(item); withAnimation { proxy.scrollTo("form", anchor: .bottom) } }
                                            InlineActionButton(title: "ลบ", systemImage: "trash", tint: .appRed) { deleteTarget = item }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    bpForm.id("form")
                    Text("แอพนี้ไม่ใช่อุปกรณ์การแพทย์ เป็นเพียงการแสดงสถิติตามตัวเลขที่ท่านบันทึกไว้")
                        .font(.footnote.weight(.semibold)).foregroundStyle(Color.appSubtext)
                }
                .onChange(of: records.count) { _, _ in withAnimation { proxy.scrollTo("latest", anchor: .top) } }
                .onChange(of: bpSaveScrollToken) { _, _ in withAnimation { proxy.scrollTo("latest", anchor: .top) } }
                 .onChange(of: showForm) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation { proxy.scrollTo("saveButton", anchor: .bottom) }
                        }
                    }
                }
            }
        }
        .alert("ยืนยันการลบ", isPresented: .constant(deleteTarget != nil), presenting: deleteTarget) { item in
            Button("ลบ", role: .destructive) { context.delete(item); saveContext(context); bpNotice = "ลบบันทึกความดันแล้ว"; bpSaveScrollToken += 1; deleteTarget = nil }
            Button("ยกเลิก", role: .cancel) { deleteTarget = nil }
        } message: { item in Text(item.valueText) }
    }

    private var bpForm: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Button { withAnimation { showForm.toggle() } } label: {
                    FormToggleButton(title: editing == nil ? "เพิ่มผลวัดความดัน" : "แก้ไขผลวัดความดัน", isOpen: showForm, color: .appBlue)
                }.buttonStyle(.plain)
                if showForm {
                    if editing != nil { UnsavedEditHint() }
                    NumberStepperRow(title: "SYS", value: $systolic, range: 70...220)
                    NumberStepperRow(title: "DIA", value: $diastolic, range: 40...140)
                    NumberStepperRow(title: "ชีพจร", value: $pulse, range: 40...140)
                    DatePicker("เวลาที่วัด", selection: $measuredAt, displayedComponents: [.date, .hourAndMinute]).font(.headline)
                    PrimaryActionButton(title: editing == nil ? "บันทึกความดัน" : "บันทึกการแก้ไขความดัน", color: .appBlue) { saveBP() }.id("saveButton")
                }
            }
        }
    }

    private func beginEdit(_ item: BloodPressureItem) { editing = item; systolic = item.systolic; diastolic = item.diastolic; pulse = item.pulse; measuredAt = item.measuredAt; showForm = true }
    private func saveBP() {
        let isEditing = editing != nil
        if let editing { editing.systolic = systolic; editing.diastolic = diastolic; editing.pulse = pulse; editing.measuredAt = measuredAt; editing.updatedAt = Date() }
        else { context.insert(BloodPressureItem(systolic: systolic, diastolic: diastolic, pulse: pulse, measuredAt: measuredAt)) }
        saveContext(context)
        bpNotice = isEditing ? "แก้ไขผลวัดความดันแล้ว: \(systolic)/\(diastolic) mmHg • ชีพจร \(pulse)" : "บันทึกผลวัดความดันแล้ว: \(systolic)/\(diastolic) mmHg • ชีพจร \(pulse)"
        editing = nil; showForm = false; bpSaveScrollToken += 1
    }
}

struct NumberStepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var body: some View {
        HStack(spacing: 10) {
            Text(title).font(.headline.weight(.heavy)).frame(width: 76, alignment: .leading)
            Button("−") { value = max(range.lowerBound, value - 1) }
                .font(.title2.weight(.heavy)).frame(width: 48, height: 44).background(Color.appBlue.opacity(0.12)).clipShape(Circle())
            Text("\(value)").font(.title2.weight(.heavy)).frame(minWidth: 62)
            Button("+") { value = min(range.upperBound, value + 1) }
                .font(.title2.weight(.heavy)).frame(width: 48, height: 44).background(Color.appBlue.opacity(0.12)).clipShape(Circle())
            Spacer()
        }
    }
}

// MARK: - Feeling

struct FeelingView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FeelingItem.recordedAt, order: .reverse) private var records: [FeelingItem]
    @State private var showForm = false
    @State private var editing: FeelingItem?
    @State private var feeling = "🙂 ปกติ / ไม่มีอะไรผิดปกติ"
    @State private var symptom = "ไม่มีอาการ"
    @State private var otherSymptom = ""
    @State private var showEmergencyAlert = false
    @State private var deleteTarget: FeelingItem?
    @State private var feelingNotice = ""
    @State private var feelingSaveScrollToken = 0

    let feelings = ["😊 สบายดีมาก", "🙂 ปกติ / ไม่มีอะไรผิดปกติ", "😟 ไม่ค่อยสบาย", "🚨 อาการรุนแรง"]
    let symptoms = ["ไม่มีอาการ", "เวียนหัว", "ปวดหัว", "เหนื่อย", "นอนไม่หลับ", "เบื่ออาหาร", "อื่น ๆ"]

    var body: some View {
        ModuleScaffold(title: "🙂 ความรู้สึกและอาการ", subtitle: "แตะเลือกเป็นหลัก ลดการพิมพ์") {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 14) {
                    HighlightCard(tint: .feelingTint, accent: .appOrange) {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionTitle(text: "ความรู้สึกและอาการวันนี้")
                            Text(records.first?.feeling ?? "ยังไม่มี")
                                .font(.title2.weight(.heavy))
                                .foregroundStyle(Color.appBlue)
                            if let latestFeeling = records.first {
                                HStack(spacing: 4) {
                                    Text("อาการที่บันทึก:")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.appText)
                                    Text(latestFeeling.symptom)
                                        .font(.headline.weight(.heavy))
                                        .foregroundStyle(Color.appBlue)
                                }
                            } else {
                                Text("เริ่มจากเลือกความรู้สึกวันนี้ แล้วเลือกอาการที่พบ")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.appSubtext)
                            }
                            Text(records.first.map { shortDateTime($0.recordedAt) } ?? "")
                                .font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext)
                        }
                    }.id("latest")
                    if !feelingNotice.isEmpty {
                        AppCard(tint: Color.appGreen.opacity(0.18)) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill").font(.title2.weight(.bold)).foregroundStyle(Color.appGreen)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ผลการบันทึกความรู้สึก").font(.headline.weight(.heavy))
                                    Text(feelingNotice).font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext)
                                }
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(text: "บันทึกทั้งหมด")
                            if records.isEmpty { Text("ยังไม่มีข้อมูล").foregroundStyle(Color.appSubtext) }
                            ForEach(records) { item in
                                ListRowCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.feeling)
                                                .font(.headline.weight(.heavy))
                                                .foregroundStyle(Color.appBlue)
                                            Text("อาการที่บันทึก: \(item.symptom) • \(shortDateTime(item.recordedAt))")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color.appSubtext)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        HStack(spacing: 10) {
                                            InlineActionButton(title: "แก้ไข", systemImage: "pencil", tint: .appBlue) { beginEdit(item); withAnimation { proxy.scrollTo("form", anchor: .bottom) } }
                                            InlineActionButton(title: "ลบ", systemImage: "trash", tint: .appRed) { deleteTarget = item }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    formCard.id("form")
                }
                .onChange(of: records.count) { _, _ in withAnimation { proxy.scrollTo("latest", anchor: .top) } }
                .onChange(of: feelingSaveScrollToken) { _, _ in withAnimation { proxy.scrollTo("latest", anchor: .top) } }
                 .onChange(of: showForm) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation { proxy.scrollTo("saveButton", anchor: .bottom) }
                        }
                    }
                }
            }
        }
        .alert("หากมีอาการรุนแรง", isPresented: $showEmergencyAlert) {
            Button("รับทราบ", role: .cancel) { }
        } message: { Text("โปรดติดต่อแพทย์ โรงพยาบาล โทรฉุกเฉิน 1669 หรือใช้เมนู SOS/ผู้ติดต่อทันที") }
        .alert("ยืนยันการลบ", isPresented: .constant(deleteTarget != nil), presenting: deleteTarget) { item in
            Button("ลบ", role: .destructive) { context.delete(item); saveContext(context); feelingNotice = "ลบบันทึกความรู้สึกและอาการแล้ว"; feelingSaveScrollToken += 1; deleteTarget = nil }
            Button("ยกเลิก", role: .cancel) { deleteTarget = nil }
        } message: { item in Text(item.summary) }
    }

    private var formCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Button { withAnimation { showForm.toggle() } } label: {
                    FormToggleButton(title: editing == nil ? "บันทึกความรู้สึกวันนี้" : "แก้ไขบันทึกความรู้สึก", isOpen: showForm, color: .appOrange)
                }.buttonStyle(.plain)
                if showForm {
                    if editing != nil { UnsavedEditHint() }
                    Text("1. วันนี้รู้สึกอย่างไร?")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Color.appOrange)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(feelings, id: \.self) { option in
                            Button {
                                feeling = option
                                if option.contains("สบายดี") || option.contains("ไม่มีอะไรผิดปกติ") {
                                    symptom = "ไม่มีอาการ"
                                    otherSymptom = ""
                                }
                                if option.contains("รุนแรง") { showEmergencyAlert = true }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(option)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.85)
                                    Spacer(minLength: 4)
                                    if feeling == option { Image(systemName: "checkmark.circle.fill") }
                                }
                                .font(.headline.weight(.heavy))
                                .padding(12)
                                .frame(minHeight: 58)
                                .background(feeling == option ? Color.appGreen.opacity(0.15) : Color.gray.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("2. มีอาการอะไรที่พบ?")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Color.appOrange)
                        .padding(.top, 2)

                    ChoiceMenu(title: "เลือกอาการที่พบ", selection: $symptom, options: symptoms)
                    if symptom == "อื่น ๆ" { OtherTextField(placeholder: "ระบุอาการที่พบ", text: $otherSymptom) }

                    Text("หากรู้สึกปกติหรือสบายดีมาก ระบบจะตั้งค่าอาการเป็น ‘ไม่มีอาการ’ ให้อัตโนมัติ สามารถเปลี่ยนได้หากต้องการ")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.appSubtext)

                    PrimaryActionButton(title: editing == nil ? "บันทึกความรู้สึกและอาการ" : "บันทึกการแก้ไขความรู้สึก", color: .appOrange) { saveFeeling() }.id("saveButton")
                }
            }
        }
    }

    private func beginEdit(_ item: FeelingItem) { editing = item; feeling = feelings.contains(item.feeling) ? item.feeling : "🙂 ปกติ / ไม่มีอะไรผิดปกติ"; symptom = symptoms.contains(item.symptom) ? item.symptom : "อื่น ๆ"; otherSymptom = symptoms.contains(item.symptom) ? "" : item.symptom; showForm = true }
    private func saveFeeling() {
        let finalSymptom = symptom == "อื่น ๆ" && !otherSymptom.isEmpty ? otherSymptom : symptom
        let isEditing = editing != nil
        if let editing { editing.feeling = feeling; editing.symptom = finalSymptom; editing.updatedAt = Date() }
        else { context.insert(FeelingItem(feeling: feeling, symptom: finalSymptom)) }
        saveContext(context)
        feelingNotice = isEditing ? "แก้ไขแล้ว: \(feeling) • อาการที่บันทึก: \(finalSymptom)" : "บันทึกแล้ว: \(feeling) • อาการที่บันทึก: \(finalSymptom)"
        editing = nil; showForm = false; feelingSaveScrollToken += 1
    }
}

// MARK: - Appointment

struct AppointmentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \AppointmentItem.dateTime, order: .forward) private var appointments: [AppointmentItem]
    @State private var showForm = false
    @State private var editing: AppointmentItem?
    @State private var type = "พบแพทย์"
    @State private var place = "โรงพยาบาล"
    @State private var dateTime = Date().addingTimeInterval(86400)
    @State private var reminder = "เตือนก่อน 1 วัน"
    @State private var otherType = ""
    @State private var otherPlace = ""
    @State private var deleteTarget: AppointmentItem?
    @State private var appointmentNotice = ""
    @State private var appointmentSaveScrollToken = 0

    var body: some View {
        ModuleScaffold(title: "📅 ปฏิทินสุขภาพ", subtitle: "แสดงเป็นรายการตามลำดับเวลา") {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 14) {
                    HighlightCard(tint: .calendarTint, accent: .appGreen) { VStack(alignment: .leading, spacing: 8) { SectionTitle(text: "นัดหมายล่าสุด/ถัดไป"); Text(appointments.first?.summary ?? "ยังไม่มีนัดหมาย").font(.title2.weight(.heavy)).foregroundStyle(Color.appBlue); Text(appointments.first.map { "\(thaiFullDateTime($0.dateTime)) • \($0.notificationStatusText)" } ?? "เพิ่มนัดหมายเพื่อช่วยจำ").font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext) } }.id("latest")
                    if !appointmentNotice.isEmpty { AppCard(tint: Color.appGreen.opacity(0.18)) { HStack(alignment: .top, spacing: 10) { Image(systemName: "checkmark.circle.fill").font(.title2.weight(.bold)).foregroundStyle(Color.appGreen); VStack(alignment: .leading, spacing: 4) { Text("ผลการตั้งเตือนนัดหมาย").font(.headline.weight(.heavy)); Text(appointmentNotice).font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext) } } } }
                    AppCard { VStack(alignment: .leading, spacing: 10) { SectionTitle(text: "รายการนัดหมายทั้งหมด"); if appointments.isEmpty { Text("ยังไม่มีข้อมูล").foregroundStyle(Color.appSubtext) }; ForEach(appointments) { item in ListRowCard { VStack(alignment: .leading, spacing: 10) { VStack(alignment: .leading, spacing: 4) { Text(item.summary).font(.headline.weight(.heavy)).foregroundStyle(Color.appBlue).fixedSize(horizontal: false, vertical: true); Text("\(thaiFullDateTime(item.dateTime)) • \(item.notificationStatusText)").font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext).fixedSize(horizontal: false, vertical: true) }; HStack(spacing: 10) { InlineActionButton(title: "แก้ไข", systemImage: "pencil", tint: .appBlue) { beginEdit(item); withAnimation { proxy.scrollTo("form", anchor: .bottom) } }; InlineActionButton(title: "ลบ", systemImage: "trash", tint: .appRed) { deleteTarget = item } } } } } } }
                    formCard.id("form")
                }.onChange(of: appointments.count) { _, _ in withAnimation { proxy.scrollTo("latest", anchor: .top) } }
                .onChange(of: appointmentSaveScrollToken) { _, _ in withAnimation { proxy.scrollTo("latest", anchor: .top) } }
                 .onChange(of: showForm) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation { proxy.scrollTo("saveButton", anchor: .bottom) }
                        }
                    }
                }
            }
        }
        .alert("ยืนยันการลบ", isPresented: .constant(deleteTarget != nil), presenting: deleteTarget) { item in Button("ลบ", role: .destructive) { AppointmentNotificationService.cancelAppointmentReminder(for: item); context.delete(item); saveContext(context); appointmentNotice = "ลบนัดหมายแล้ว และยกเลิกแจ้งเตือนของนัดหมายนี้แล้ว"; appointmentSaveScrollToken += 1; deleteTarget = nil }; Button("ยกเลิก", role: .cancel) { deleteTarget = nil } } message: { item in Text(item.summary) }
    }

    private var formCard: some View {
        AppCard { VStack(alignment: .leading, spacing: 10) { Button { withAnimation { showForm.toggle() } } label: { FormToggleButton(title: editing == nil ? "เพิ่มนัดหมายสุขภาพ" : "แก้ไขนัดหมายสุขภาพ", isOpen: showForm, color: .appGreen) }.buttonStyle(.plain); if showForm { if editing != nil { UnsavedEditHint() }; ChoiceMenu(title: "ประเภท", selection: $type, options: ["พบแพทย์", "รับยา", "ตรวจเลือด", "ฉีดวัคซีน", "กายภาพ", "อื่น ๆ"]); if type == "อื่น ๆ" { OtherTextField(placeholder: "ระบุประเภทนัดหมาย", text: $otherType) }; ChoiceMenu(title: "สถานที่", selection: $place, options: ["โรงพยาบาล", "คลินิก", "สถานีอนามัย", "บ้าน", "อื่น ๆ"]); if place == "อื่น ๆ" { OtherTextField(placeholder: "ระบุสถานที่", text: $otherPlace) }; DatePicker("วันและเวลา", selection: $dateTime, displayedComponents: [.date, .hourAndMinute]).font(.headline); Text("เลือกไว้: \(thaiFullDateTime(dateTime))").font(.subheadline.weight(.heavy)).foregroundStyle(Color.appBlue); ChoiceMenu(title: "การเตือน", selection: $reminder, options: ["ไม่เตือน", "เตือนก่อน 1 ชั่วโมง", "เตือนก่อน 1 วัน", "เตือนก่อน 3 วัน"]); PrimaryActionButton(title: editing == nil ? "บันทึกนัดหมาย" : "บันทึกการแก้ไขนัดหมาย", color: .appGreen) { saveAppointment() }.id("saveButton") } } }
    }
    private func resolved(_ s: String, _ other: String) -> String { s == "อื่น ๆ" && !other.isEmpty ? other : s }
    private func beginEdit(_ item: AppointmentItem) { editing = item; type = ["พบแพทย์", "รับยา", "ตรวจเลือด", "ฉีดวัคซีน", "กายภาพ"].contains(item.type) ? item.type : "อื่น ๆ"; otherType = type == "อื่น ๆ" ? item.type : ""; place = ["โรงพยาบาล", "คลินิก", "สถานีอนามัย", "บ้าน"].contains(item.place) ? item.place : "อื่น ๆ"; otherPlace = place == "อื่น ๆ" ? item.place : ""; dateTime = item.dateTime; reminder = item.reminder; showForm = true }
    private func saveAppointment() {
        let finalType = resolved(type, otherType)
        let finalPlace = resolved(place, otherPlace)
        let targetItem: AppointmentItem
        let isEditing = editing != nil

        if let editing {
            editing.type = finalType
            editing.place = finalPlace
            editing.dateTime = dateTime
            editing.reminder = reminder
            editing.updatedAt = Date()
            targetItem = editing
        } else {
            let newItem = AppointmentItem(type: finalType, place: finalPlace, dateTime: dateTime, reminder: reminder)
            context.insert(newItem)
            targetItem = newItem
        }

        saveContext(context)
        AppointmentNotificationService.scheduleAppointmentReminder(for: targetItem) { message in
            appointmentNotice = isEditing ? "แก้ไขนัดหมายแล้ว: \(finalType) • \(finalPlace) • \(thaiFullDateTime(dateTime)) • \(message)" : "บันทึกนัดหมายแล้ว: \(finalType) • \(finalPlace) • \(thaiFullDateTime(dateTime)) • \(message)"
            appointmentSaveScrollToken += 1
            saveContext(context)
        }
        editing = nil
        showForm = false
        appointmentSaveScrollToken += 1
    }
}

// MARK: - SOS

struct SOSView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SOSContactItem.updatedAt, order: .reverse) private var contacts: [SOSContactItem]
    @State private var showForm = false
    @State private var editing: SOSContactItem?
    @State private var name = "ลูกชาย"
    @State private var relation = "ลูก"
    @State private var phone = "0812345678"
    @State private var otherName = ""
    @State private var otherRelation = ""
    @State private var otherPhone = ""
    @State private var callTarget: SOSContactItem?
    @State private var deleteTarget: SOSContactItem?
    @State private var sosNotice = ""
    @State private var sosSaveScrollToken = 0

    var primary: SOSContactItem? { contacts.first(where: { $0.isPrimary }) ?? contacts.first }

    var body: some View {
        ModuleScaffold(title: "🆘 SOS/ผู้ติดต่อ", subtitle: "เปิดแอปโทรศัพท์หลังยืนยัน") {
            ScrollViewReader { proxy in
                VStack(alignment: .leading, spacing: 14) {
                    if let primary {
                        Button { callTarget = primary } label: {
                            HighlightCard(tint: .sosTint, accent: .appRed) { HStack { VStack(alignment: .leading, spacing: 6) { Text("ผู้ติดต่อหลัก").font(.headline.weight(.heavy)); Text(primary.name).font(.title2.weight(.heavy)).foregroundStyle(Color.appBlue); Text("\(primary.relationship) • \(primary.phone)").font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext) }; Spacer(); Image(systemName: "phone.fill").font(.title2.weight(.heavy)).foregroundStyle(Color.appRed) } }
                        }.buttonStyle(.plain).id("latest")
                    } else { HighlightCard(tint: .sosTint, accent: .appRed) { Text("ยังไม่มีผู้ติดต่อหลัก").font(.headline.weight(.heavy)) }.id("latest") }
                    if !sosNotice.isEmpty {
                        AppCard(tint: Color.appGreen.opacity(0.18)) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill").font(.title2.weight(.bold)).foregroundStyle(Color.appGreen)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ผลการบันทึกผู้ติดต่อ").font(.headline.weight(.heavy))
                                    Text(sosNotice).font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext)
                                }
                            }
                        }
                    }

                    AppCard { VStack(alignment: .leading, spacing: 10) { SectionTitle(text: "รายชื่อผู้ติดต่อ") ; if contacts.isEmpty { Text("ยังไม่มีข้อมูล").foregroundStyle(Color.appSubtext) }; ForEach(contacts) { item in ListRowCard { VStack(alignment: .leading, spacing: 8) { HStack { VStack(alignment: .leading) { Text(item.name + (item.isPrimary ? "  ⭐ หลัก" : "")).font(.headline.weight(.heavy)); Text("\(item.relationship) • \(item.phone)").font(.subheadline.weight(.semibold)).foregroundStyle(Color.appSubtext) }; Spacer() }; LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) { InlineActionButton(title: "โทร", systemImage: "phone", tint: .appGreen) { callTarget = item }; if !item.isPrimary { InlineActionButton(title: "ใช้เป็นหลัก", systemImage: "star", tint: .appOrange) { setPrimary(item) } }; InlineActionButton(title: "แก้ไข", systemImage: "pencil", tint: .appBlue) { beginEdit(item); withAnimation { proxy.scrollTo("form", anchor: .bottom) } }; InlineActionButton(title: "ลบ", systemImage: "trash", tint: .appRed) { deleteTarget = item } } } } } } }
                    formCard.id("form")
                }
                .onChange(of: sosSaveScrollToken) { _, _ in withAnimation { proxy.scrollTo("latest", anchor: .top) } }
                 .onChange(of: showForm) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                            withAnimation { proxy.scrollTo("saveButton", anchor: .bottom) }
                        }
                    }
                }
            }
        }
        .alert("ระบบกำลังจะเปิดแอปพลิเคชันโทรศัพท์ของเครื่องเพื่อโทรออก", isPresented: .constant(callTarget != nil), presenting: callTarget) { item in
            Button("เปิดโทรศัพท์") { openPhone(item.phone); callTarget = nil }
            Button("ยกเลิก", role: .cancel) { callTarget = nil }
        } message: { item in Text("โทรหา \(item.name) \(item.phone)") }
        .alert("ยืนยันการลบ", isPresented: .constant(deleteTarget != nil), presenting: deleteTarget) { item in Button("ลบ", role: .destructive) { context.delete(item); saveContext(context); sosNotice = "ลบผู้ติดต่อแล้ว"; sosSaveScrollToken += 1; deleteTarget = nil }; Button("ยกเลิก", role: .cancel) { deleteTarget = nil } } message: { item in Text(item.name) }
    }

    private var formCard: some View { AppCard { VStack(alignment: .leading, spacing: 10) { Button { withAnimation { showForm.toggle() } } label: { FormToggleButton(title: editing == nil ? "เพิ่มผู้ติดต่อ" : "แก้ไขผู้ติดต่อ", isOpen: showForm, color: .appRed) }.buttonStyle(.plain); if showForm { if editing != nil { UnsavedEditHint() }; ChoiceMenu(title: "ชื่อ", selection: $name, options: ["ลูกชาย", "ลูกสาว", "คู่สมรส", "ผู้ดูแล", "อื่น ๆ"]); if name == "อื่น ๆ" { OtherTextField(placeholder: "ระบุชื่อ", text: $otherName) }; ChoiceMenu(title: "ความสัมพันธ์", selection: $relation, options: ["ลูก", "คู่สมรส", "ญาติ", "เพื่อนบ้าน", "ผู้ดูแล", "อื่น ๆ"]); if relation == "อื่น ๆ" { OtherTextField(placeholder: "ระบุความสัมพันธ์", text: $otherRelation) }; ChoiceMenu(title: "หมายเลข", selection: $phone, options: ["0812345678", "0899999999", "1669", "อื่น ๆ"]); if phone == "อื่น ๆ" { OtherTextField(placeholder: "กรอกเบอร์โทรศัพท์", text: $otherPhone) }; PrimaryActionButton(title: editing == nil ? "บันทึกผู้ติดต่อ" : "บันทึกการแก้ไขผู้ติดต่อ", color: .appRed) { saveContact() }.id("saveButton") } } } }
    private func resolved(_ s: String, _ other: String) -> String { s == "อื่น ๆ" && !other.isEmpty ? other : s }
    private func beginEdit(_ item: SOSContactItem) { editing = item; name = ["ลูกชาย", "ลูกสาว", "คู่สมรส", "ผู้ดูแล"].contains(item.name) ? item.name : "อื่น ๆ"; otherName = name == "อื่น ๆ" ? item.name : ""; relation = ["ลูก", "คู่สมรส", "ญาติ", "เพื่อนบ้าน", "ผู้ดูแล"].contains(item.relationship) ? item.relationship : "อื่น ๆ"; otherRelation = relation == "อื่น ๆ" ? item.relationship : ""; phone = ["0812345678", "0899999999", "1669"].contains(item.phone) ? item.phone : "อื่น ๆ"; otherPhone = phone == "อื่น ๆ" ? item.phone : ""; showForm = true }
    private func saveContact() { let finalName = resolved(name, otherName); let finalRelation = resolved(relation, otherRelation); let finalPhone = resolved(phone, otherPhone); let isEditing = editing != nil; if let editing { editing.name = finalName; editing.relationship = finalRelation; editing.phone = finalPhone; editing.updatedAt = Date() } else { let makePrimary = contacts.isEmpty; context.insert(SOSContactItem(name: finalName, relationship: finalRelation, phone: finalPhone, isPrimary: makePrimary)) }; saveContext(context); sosNotice = isEditing ? "แก้ไขผู้ติดต่อแล้ว: \(finalName) • \(finalRelation) • \(finalPhone)" : "บันทึกผู้ติดต่อแล้ว: \(finalName) • \(finalRelation) • \(finalPhone)"; editing = nil; showForm = false; sosSaveScrollToken += 1 }
    private func setPrimary(_ item: SOSContactItem) { contacts.forEach { $0.isPrimary = false }; item.isPrimary = true; item.updatedAt = Date(); saveContext(context); sosNotice = "ตั้งเป็นผู้ติดต่อหลักแล้ว: \(item.name) • \(item.relationship) • \(item.phone)"; sosSaveScrollToken += 1 }
    private func openPhone(_ phone: String) { if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) } }
}


struct UnsavedEditHint: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.appOrange)
            Text("กำลังแก้ไขรายการเดิม กรุณากดปุ่มบันทึกการแก้ไขก่อนกลับหน้าแรก มิฉะนั้นข้อมูลที่แก้จะยังไม่ถูกบันทึก")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appSubtext)
        }
        .padding(10)
        .background(Color.appOrange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Settings

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
            csv = makeCSV(headers: ["ชื่อยา", "รูปแบบ", "ปริมาณ", "วิธีใช้", "เวลาเตือน", "สถานะแจ้งเตือน", "วันที่สร้าง", "แก้ไขล่าสุด"], rows: medications.map { [
                $0.name, $0.form, $0.dosage, $0.instruction, $0.timeText, $0.notificationIdentifier == nil ? "ยังไม่ได้ตั้งแจ้งเตือน" : "ตั้งแจ้งเตือนแล้ว", shortDateTime($0.createdAt), shortDateTime($0.updatedAt)
            ]})
        case .medicationLogs:
            csv = makeCSV(headers: ["ชื่อยา", "สถานะ", "วันที่เวลา"], rows: logs.map { [$0.medicationName, $0.status, shortDateTime($0.loggedAt)] })
        case .bloodPressure:
            csv = makeCSV(headers: ["SYS", "DIA", "ชีพจร", "วันที่เวลา", "หมายเหตุ"], rows: bp.map { [String($0.systolic), String($0.diastolic), String($0.pulse), shortDateTime($0.measuredAt), $0.note] })
        case .feelings:
            csv = makeCSV(headers: ["ความรู้สึก", "อาการที่บันทึก", "วันที่เวลา"], rows: feelings.map { [$0.feeling, $0.symptom, shortDateTime($0.recordedAt)] })
        case .appointments:
            csv = makeCSV(headers: ["ประเภท", "สถานที่", "วันเวลา", "การเตือน", "สถานะแจ้งเตือน"], rows: appointments.map { [$0.type, $0.place, thaiFullDateTime($0.dateTime), $0.reminder, $0.notificationStatusText] })
        case .contacts:
            csv = makeCSV(headers: ["ชื่อ", "ความสัมพันธ์", "เบอร์โทร", "ผู้ติดต่อหลัก"], rows: contacts.map { [$0.name, $0.relationship, $0.phone, $0.isPrimary ? "ใช่" : "ไม่ใช่"] })
        }
        writeExportFile(fileName: kind.fileName, content: csv, kindName: kind.thaiName)
    }

    private func exportPDFSummary() {
        let fileName = "phuean_tuenya_30_day_summary.pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let recentMeds = Array(medications.prefix(6))
        let recentLogs = Array(logs.prefix(8))
        let recentBP = Array(bp.prefix(8))
        let recentFeelings = Array(feelings.prefix(8))
        let recentAppointments = Array(appointments.prefix(8))
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
                drawText("วันที่สร้างรายงาน: \(shortDateTime(Date()))", font: bodyFont, color: .darkGray, spacing: 10)

                drawText("⚠️ รายงานนี้สร้างจากข้อมูลที่ผู้ใช้บันทึกไว้เองในเครื่องเท่านั้น ไม่ใช่การวิเคราะห์ วินิจฉัย หรือคำแนะนำทางการแพทย์", font: subheadFont, color: .black, spacing: 8)
                drawText("ก่อนส่งต่อไฟล์นี้ ผู้ใช้ควรตรวจสอบข้อมูลและเป็นผู้ตัดสินใจส่งออกด้วยตนเอง ข้อมูลที่ส่งออกไปยังแอปภายนอกจะอยู่นอกการคุ้มครองของเครื่องนี้", font: smallFont, color: .darkGray, spacing: 12)
                drawDivider()

                drawSection("1) สรุปภาพรวม", rows: [
                    "รายการยา: \(medications.count) รายการ",
                    "ประวัติกินยา: \(logs.count) รายการ",
                    "บันทึกความดัน: \(bp.count) รายการ",
                    "บันทึกความรู้สึกและอาการ: \(feelings.count) รายการ",
                    "นัดหมายสุขภาพ: \(appointments.count) รายการ",
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

    private func makeCSV(headers: [String], rows: [[String]]) -> String {
        ([headers] + rows).map { row in row.map(csvEscape).joined(separator: ",") }.joined(separator: "\n")
    }

    private func csvEscape(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
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

    private func clearAll() { medications.forEach { context.delete($0) }; logs.forEach { context.delete($0) }; bp.forEach { context.delete($0) }; feelings.forEach { context.delete($0) }; appointments.forEach { context.delete($0) }; contacts.forEach { context.delete($0) }; saveContext(context); settingsScrollTarget = "settingsResult"; result = "ล้างข้อมูลทั้งหมดแล้ว" }
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

// MARK: - Shared Scaffold

struct ModuleScaffold<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.appSoftBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        HeaderView(title: title, subtitle: subtitle)
                        Button { dismiss() } label: { Image(systemName: "house.fill").font(.title3.weight(.heavy)).foregroundStyle(Color.appBlue).padding(10).background(Color.white).clipShape(Circle()) }
                    }
                    content
                    Text("⚠️ แอปนี้ไม่ใช่เครื่องมือแพทย์ ข้อมูลแสดงตามที่ผู้ใช้บันทึกไว้เท่านั้น")
                        .font(.footnote.weight(.semibold)).foregroundStyle(Color.appSubtext).padding(.bottom, 20)
                }
                .padding(16)
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

// MARK: - Medication Local Notifications

final class MedicationNotificationService {
    private static let prefix = "medication-reminder-"

    private static func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(true) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func scheduleMedicationReminder(for medication: MedicationItem, completion: @escaping (String) -> Void) {
        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }

            let identifier = medication.notificationIdentifier ?? prefix + UUID().uuidString
            medication.notificationIdentifier = identifier

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

            let content = UNMutableNotificationContent()
            content.title = "เพื่อนเตือนยา"
            content.body = "ถึงเวลา \(medication.name) • \(medication.dosage) • \(medication.instruction)"
            content.sound = .default
            content.badge = 1

            let parts = medication.timeText.split(separator: ":").compactMap { Int($0) }
            var dateComponents = DateComponents()
            dateComponents.hour = parts.count > 0 ? parts[0] : 8
            dateComponents.minute = parts.count > 1 ? parts[1] : 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error {
                        completion("ตั้งแจ้งเตือนไม่สำเร็จ: \(error.localizedDescription)")
                    } else {
                        completion("ตั้งแจ้งเตือนยา \(medication.name) เวลา \(medication.timeText) น. แล้ว")
                    }
                }
            }
        }
    }

    static func rescheduleAllMedicationReminders(for medications: [MedicationItem], completion: @escaping (String) -> Void) {
        guard !medications.isEmpty else {
            completion("ยังไม่มีรายการยาให้ตั้งแจ้งเตือน")
            return
        }

        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }

            var scheduledCount = 0
            let group = DispatchGroup()

            for medication in medications {
                group.enter()
                scheduleMedicationReminder(for: medication) { _ in
                    scheduledCount += 1
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion("ตรวจแล้ว ตั้งเตือนยาสำเร็จ \(scheduledCount) จาก \(medications.count) รายการ")
            }
        }
    }

    static func cancelMedicationReminder(for medication: MedicationItem) {
        if let identifier = medication.notificationIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            medication.notificationIdentifier = nil
        }
    }

    static func cancelMedicationReminders(for medications: [MedicationItem]) {
        let identifiers = medications.compactMap { $0.notificationIdentifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    static func scheduleTestNotification(completion: @escaping (String) -> Void) {
        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "เพื่อนเตือนยา"
            content.body = "นี่คือการทดสอบการแจ้งเตือน หากเห็นข้อความนี้ แปลว่าระบบแจ้งเตือนทำงาน"
            content.sound = .default
            let req = UNNotificationRequest(identifier: "test-" + UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
            UNUserNotificationCenter.current().add(req) { _ in
                DispatchQueue.main.async { completion("ตั้งการทดสอบแจ้งเตือนแล้ว กรุณารอประมาณ 5 วินาที หากเห็น banner แปลว่าระบบแจ้งเตือนทำงาน") }
            }
        }
    }
}


// MARK: - Health Calendar Local Notifications

final class AppointmentNotificationService {
    private static let prefix = "appointment-reminder-"

    private static func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(true) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    private static func reminderOffsetSeconds(for reminder: String) -> TimeInterval? {
        switch reminder {
        case "เตือนก่อน 1 ชั่วโมง": return 60 * 60
        case "เตือนก่อน 1 วัน": return 24 * 60 * 60
        case "เตือนก่อน 3 วัน": return 3 * 24 * 60 * 60
        default: return nil
        }
    }

    static func scheduleAppointmentReminder(for appointment: AppointmentItem, completion: @escaping (String) -> Void) {
        guard let offset = reminderOffsetSeconds(for: appointment.reminder) else {
            cancelAppointmentReminder(for: appointment)
            completion("ไม่ได้ตั้งแจ้งเตือน เพราะเลือกไม่เตือน")
            return
        }

        let triggerDate = appointment.dateTime.addingTimeInterval(-offset)
        guard triggerDate > Date().addingTimeInterval(5) else {
            cancelAppointmentReminder(for: appointment)
            completion("ยังไม่ได้ตั้งแจ้งเตือน เพราะเวลาเตือนผ่านไปแล้วหรือใกล้เกินไป")
            return
        }

        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }

            let identifier = appointment.notificationIdentifier ?? prefix + UUID().uuidString
            appointment.notificationIdentifier = identifier
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

            let content = UNMutableNotificationContent()
            content.title = "เพื่อนเตือนยา: นัดหมายสุขภาพ"
            content.body = "\(appointment.type) • \(appointment.place) • \(shortDateTime(appointment.dateTime))"
            content.sound = .default
            content.badge = 1

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error {
                        completion("ตั้งแจ้งเตือนนัดหมายไม่สำเร็จ: \(error.localizedDescription)")
                    } else {
                        completion("ตั้งแจ้งเตือนนัดหมาย \(appointment.type) • \(appointment.reminder) แล้ว")
                    }
                }
            }
        }
    }

    static func rescheduleAllAppointmentReminders(for appointments: [AppointmentItem], completion: @escaping (String) -> Void) {
        let targets = appointments.filter { $0.reminder != "ไม่เตือน" }
        guard !appointments.isEmpty else {
            completion("ยังไม่มีนัดหมายสุขภาพให้ตั้งแจ้งเตือน")
            return
        }
        guard !targets.isEmpty else {
            completion("มีนัดหมาย \(appointments.count) รายการ แต่ทั้งหมดเลือกไม่เตือน")
            return
        }

        var completedCount = 0
        var scheduledCount = 0

        for appointment in targets {
            scheduleAppointmentReminder(for: appointment) { message in
                completedCount += 1
                if message.contains("ตั้งแจ้งเตือนนัดหมาย") { scheduledCount += 1 }
                if completedCount == targets.count {
                    completion("ตรวจแล้ว ตั้งเตือนนัดหมายสำเร็จ \(scheduledCount) จาก \(targets.count) รายการ")
                }
            }
        }
    }

    static func cancelAppointmentReminder(for appointment: AppointmentItem) {
        if let identifier = appointment.notificationIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            appointment.notificationIdentifier = nil
        }
    }

    static func cancelAppointmentReminders(for appointments: [AppointmentItem]) {
        let identifiers = appointments.compactMap { $0.notificationIdentifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

// MARK: - Persistence Helpers

private func saveContext(_ context: ModelContext) {
    do { try context.save() } catch { print("SwiftData save error: \(error)") }
}

private func makeTimeDate(hour: Int, minute: Int) -> Date {
    Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
}

private func dateFromTimeText(_ text: String) -> Date {
    let parts = text.split(separator: ":").compactMap { Int($0) }
    guard parts.count >= 2 else { return makeTimeDate(hour: 8, minute: 0) }
    return makeTimeDate(hour: parts[0], minute: parts[1])
}

private func timeOnlyText(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "th_TH")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}


private extension String {
    func height(constrainedTo width: CGFloat, font: UIFont) -> CGFloat {
        let rect = self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return ceil(rect.height)
    }
}
