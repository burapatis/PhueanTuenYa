import SwiftUI

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
