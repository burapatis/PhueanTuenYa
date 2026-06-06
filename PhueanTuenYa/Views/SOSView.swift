import SwiftUI
import SwiftData
import UIKit

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

