import SwiftUI
import SwiftData
import UserNotifications

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
    @State private var selectedMedLocalID: UUID?
    @State private var deleteTarget: MedicationItem?
    @State private var deleteLogTarget: MedicationLogItem?
    @State private var medicationSaveScrollToken = 0
    @State private var medicationNotice = ""

    private var todayLogs: [MedicationLogItem] {
        logs.filter { Calendar.current.isDateInToday($0.loggedAt) }
    }

    private var selectedMedication: MedicationItem? {
        guard let selectedMedLocalID else { return nil }
        return medications.first(where: { $0.localID == selectedMedLocalID })
    }

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
                .onAppear {
                    medications.forEach { _ = $0.ensureLocalID() }
                    if selectedMedLocalID == nil { selectedMedLocalID = medications.first.map { $0.ensureLocalID() } }
                    reminderTime = dateFromTimeText(timeText)
                }
                .onChange(of: medications.count) { _, _ in
                    if selectedMedication == nil { selectedMedLocalID = medications.first.map { $0.ensureLocalID() } }
                }
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
                medicationPicker
                HStack(spacing: 8) {
                    statusButton("กินแล้ว", .appGreen)
                    statusButton("ข้าม", .appOrange)
                    statusButton("เตือนอีก 10 นาที", .appBlue)
                }
                if !todayLogs.isEmpty {
                    Text("ประวัติกินยาวันนี้").font(.headline.weight(.heavy))
                    ForEach(todayLogs) { log in
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

    private var medicationPicker: some View {
        HStack {
            Text("เลือกรายการยา")
                .font(.headline)
            Spacer()
            if medications.isEmpty {
                Text("ยังไม่มีรายการยา")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appSubtext)
            } else {
                Menu {
                    ForEach(medications) { item in
                        Button(item.selectionLabel) { selectedMedLocalID = item.ensureLocalID() }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedMedication?.selectionLabel ?? "เลือกรายการยา")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.appBlue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(.vertical, 3)
    }

    private func statusButton(_ text: String, _ color: Color) -> some View {
        Button(text) {
            guard let med = selectedMedication else { return }
            let localID = med.ensureLocalID()
            context.insert(MedicationLogItem(medicationName: med.name, status: text, medicationLocalID: localID))
            saveContext(context)
            if text == "เตือนอีก 10 นาที" {
                MedicationNotificationService.scheduleSnoozeReminder(
                    medicationName: med.name,
                    dosage: med.dosage,
                    instruction: med.instruction
                ) { message in
                    medicationNotice = message
                    medicationSaveScrollToken += 1
                }
            } else {
                medicationNotice = "บันทึกสถานะ ‘\(text)’ ของ \(med.name) แล้ว"
                medicationSaveScrollToken += 1
            }
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

        selectedMedLocalID = targetItem.ensureLocalID()
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
