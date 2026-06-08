import SwiftUI

private enum AppLegalURLs {
    static let privacy = URL(string: "https://burapatis.github.io/app/apps/pheuan-tueanya/privacy.html")!
    static let terms = URL(string: "https://burapatis.github.io/app/apps/pheuan-tueanya/terms.html")!
    static let support = URL(string: "https://burapatis.github.io/app/apps/pheuan-tueanya/support.html")!
}

struct ContentView: View {
    @AppStorage("hasAcceptedFirstLaunchConsent_v0_6_4_fix1") private var hasAcceptedConsent = false
    @AppStorage("hasSeenSimpleUsageGuide_v0_6_4_fix1") private var hasSeenSimpleGuide = false

    var body: some View {
        Group {
            if !hasAcceptedConsent {
                FirstLaunchConsentView {
                    hasAcceptedConsent = true
                }
            } else if !hasSeenSimpleGuide {
                SimpleUsageGuideView {
                    hasSeenSimpleGuide = true
                }
            } else {
                HomeView()
            }
        }
        .preferredColorScheme(.light)
    }
}

struct SimpleUsageGuideView: View {
    let onAccept: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBlue.opacity(0.96), Color.appNavy.opacity(0.88), Color.appSoftBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("วิธีใช้งานอย่างง่าย")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("แตะเมนูบนหน้าแรก แล้วเลือกหรือบันทึกตามขั้นตอน")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 8) {
                        guideRow(icon: "💊", title: "ยา", detail: "เพิ่มรายการยา เลือกเวลาเตือน และบันทึกกินยาในวันนี้")
                        guideRow(icon: "🩺", title: "ความดัน", detail: "บันทึกค่าความดันและชีพจรตามที่วัดได้")
                        guideRow(icon: "🙂", title: "ความรู้สึกและอาการ", detail: "เลือกความรู้สึกวันนี้ แล้วเลือกอาการที่พบถ้ามี")
                        guideRow(icon: "📅", title: "ปฏิทินสุขภาพ", detail: "เพิ่มนัดหมายสุขภาพ และเลือกเวลาการแจ้งเตือน")
                        guideRow(icon: "🆘", title: "SOS/ผู้ติดต่อ", detail: "เพิ่มผู้ติดต่อหลัก และแตะเพื่อเปิดแอปโทรศัพท์เมื่อจำเป็น")
                        guideRow(icon: "📝", title: "การบันทึกข้อมูล", detail: "ผู้บันทึกข้อมูล/ผู้ใช้ต้องรับผิดชอบการบันทึกข้อมูลทั้งหมดด้วยตนเอง")
                        guideRow(icon: "⚙️", title: "ตั้งค่า", detail: "ส่งออก CSV/PDF ดูข้อตกลง วิธีใช้ และล้างข้อมูลเมื่อจำเป็น")
                        legalLinkCard(
                            title: "ความช่วยเหลือเพิ่มเติม",
                            links: [("💬 หน้าเว็บไซต์ความช่วยเหลือ", AppLegalURLs.support)]
                        )
                    }
                }

                Button(action: onAccept) {
                    HStack(spacing: 8) {
                        Text("✅")
                        Text("รับทราบและเริ่มใช้งาน")
                    }
                    .font(.headline.weight(.heavy))
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .background(Color.appGreen)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(18)
        }
    }

    private func guideRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Color.appText)
                Text(detail)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appSubtext)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct FirstLaunchConsentView: View {
    let onAccept: () -> Void
    @State private var hasReadAndAccepted = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appNavy, Color.appBlue.opacity(0.92), Color.appSoftBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("เพื่อนเตือนยา")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("ข้อตกลงก่อนเริ่มใช้งาน")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.96))
                    Text("อ่านให้ครบก่อนกดรับทราบ")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.88))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 8) {
                        consentRow(icon: "⚠️", title: "ไม่ใช่เครื่องมือแพทย์", detail: "ช่วยจำและบันทึกเท่านั้น ไม่วิเคราะห์ วินิจฉัย หรือให้คำปรึกษาทางการแพทย์")
                        consentRow(icon: "🔒", title: "ข้อมูลอยู่ในเครื่องนี้", detail: "ไม่มีสมัครสมาชิก ไม่มี backend ผู้พัฒนาแอพฯ ไม่สามารถเข้าถึงหรือรู้ข้อมูลที่ผู้ใช้บันทึกได้")
                        consentRow(icon: "👤", title: "ผู้ใช้ควบคุมข้อมูลเอง", detail: "เพิ่ม ดู แก้ไข ลบ และส่งออกข้อมูลได้ด้วยตนเองเมื่อจำเป็น")
                        consentRow(icon: "🆘", title: "กรณีผิดปกติหรือฉุกเฉิน", detail: "ติดต่อแพทย์ โรงพยาบาล โทร 1669 หรือใช้เมนู SOS/ผู้ติดต่อทันที")
                        legalLinkCard(
                            title: "เอกสารทางกฎหมาย",
                            links: [
                                ("🔒 นโยบายความเป็นส่วนตัว", AppLegalURLs.privacy),
                                ("📋 ข้อกำหนดการใช้งาน", AppLegalURLs.terms)
                            ]
                        )
                        Text("หากท่านไม่ยอมรับ/ตกลงตามข้อตกลง ขอให้ถอนการติดตั้งแอพออกจากเครื่องทันที")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white.opacity(0.95))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Button {
                    hasReadAndAccepted.toggle()
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: hasReadAndAccepted ? "checkmark.square.fill" : "square")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(hasReadAndAccepted ? Color.appGreen : .white.opacity(0.9))
                        Text("ข้าพเจ้าได้อ่านและยอมรับข้อตกลงทั้งหมดแล้ว")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                Button(action: onAccept) {
                    HStack(spacing: 8) {
                        Text("✅")
                        Text("รับทราบและยินยอมปฏิบัติตามข้อตกลงนี้")
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .font(.headline.weight(.heavy))
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .background(hasReadAndAccepted ? Color.appGreen : Color.gray.opacity(0.45))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
                .disabled(!hasReadAndAccepted)
            }
            .padding(18)
        }
    }

    private func consentRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Color.appText)
                Text(detail)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appSubtext)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private func legalLinkCard(title: String, links: [(String, URL)]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.headline.weight(.heavy))
            .foregroundStyle(Color.appText)
        ForEach(Array(links.enumerated()), id: \.offset) { _, link in
            Link(destination: link.1) {
                HStack(spacing: 8) {
                    Text(link.0)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appBlue)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.appBlue)
                }
            }
        }
    }
    .padding(11)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white.opacity(0.96))
    .clipShape(RoundedRectangle(cornerRadius: 18))
}
