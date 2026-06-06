import SwiftUI
import SwiftData

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
