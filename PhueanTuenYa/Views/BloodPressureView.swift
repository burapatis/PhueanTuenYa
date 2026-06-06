import SwiftUI
import SwiftData

struct BloodPressureView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BloodPressureItem.measuredAt, order: .reverse) private var records: [BloodPressureItem]
    @State private var showForm = false
    @State private var editing: BloodPressureItem?
    @State private var systolic = 120
    @State private var diastolic = 80
    @State private var pulse = 72
    @State private var measuredAt = Date()
    @State private var note = ""
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
                    OtherTextField(placeholder: "หมายเหตุ (ถ้ามี)", text: $note)
                    PrimaryActionButton(title: editing == nil ? "บันทึกความดัน" : "บันทึกการแก้ไขความดัน", color: .appBlue) { saveBP() }.id("saveButton")
                }
            }
        }
    }

    private func beginEdit(_ item: BloodPressureItem) { editing = item; systolic = item.systolic; diastolic = item.diastolic; pulse = item.pulse; measuredAt = item.measuredAt; note = item.note; showForm = true }
    private func saveBP() {
        let isEditing = editing != nil
        if let editing { editing.systolic = systolic; editing.diastolic = diastolic; editing.pulse = pulse; editing.measuredAt = measuredAt; editing.note = note; editing.updatedAt = Date() }
        else { context.insert(BloodPressureItem(systolic: systolic, diastolic: diastolic, pulse: pulse, measuredAt: measuredAt, note: note)) }
        saveContext(context)
        let noteSuffix = note.isEmpty ? "" : " • หมายเหตุ: \(note)"
        bpNotice = isEditing ? "แก้ไขผลวัดความดันแล้ว: \(systolic)/\(diastolic) mmHg • ชีพจร \(pulse)\(noteSuffix)" : "บันทึกผลวัดความดันแล้ว: \(systolic)/\(diastolic) mmHg • ชีพจร \(pulse)\(noteSuffix)"
        editing = nil; note = ""; showForm = false; bpSaveScrollToken += 1
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
