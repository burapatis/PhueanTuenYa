import SwiftUI
import SwiftData

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
