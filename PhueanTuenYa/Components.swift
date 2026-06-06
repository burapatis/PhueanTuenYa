import SwiftUI
import SwiftData
import UserNotifications

// MARK: - SwiftData Models

@Model
final class MedicationItem {
    var localID: UUID?
    var name: String
    var form: String
    var dosage: String
    var instruction: String
    var timeText: String
    var notificationIdentifier: String?
    var createdAt: Date
    var updatedAt: Date

    init(name: String, form: String, dosage: String, instruction: String, timeText: String, createdAt: Date = Date()) {
        self.localID = UUID()
        self.name = name
        self.form = form
        self.dosage = dosage
        self.instruction = instruction
        self.timeText = timeText
        self.notificationIdentifier = nil
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }

    var summary: String { "\(name) • \(dosage) • \(timeText)" }
    var selectionLabel: String { "\(name) • \(dosage) • \(timeText)" }

    func ensureLocalID() -> UUID {
        if let localID { return localID }
        let newID = UUID()
        self.localID = newID
        return newID
    }
}

@Model
final class MedicationLogItem {
    var medicationName: String
    var medicationLocalID: UUID?
    var status: String
    var loggedAt: Date

    init(medicationName: String, status: String, medicationLocalID: UUID? = nil, loggedAt: Date = Date()) {
        self.medicationName = medicationName
        self.medicationLocalID = medicationLocalID
        self.status = status
        self.loggedAt = loggedAt
    }

    var summary: String { "\(medicationName) • \(status)" }
}

@Model
final class BloodPressureItem {
    var systolic: Int
    var diastolic: Int
    var pulse: Int
    var measuredAt: Date
    var note: String
    var updatedAt: Date

    init(systolic: Int, diastolic: Int, pulse: Int, measuredAt: Date = Date(), note: String = "") {
        self.systolic = systolic
        self.diastolic = diastolic
        self.pulse = pulse
        self.measuredAt = measuredAt
        self.note = note
        self.updatedAt = measuredAt
    }

    var valueText: String { "\(systolic)/\(diastolic)" }
    var detailText: String { "mmHg • ชีพจร \(pulse) • \(Self.shortDateTime(measuredAt))" }

    static func shortDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "th_TH")
        formatter.dateFormat = "d MMM HH:mm"
        return formatter.string(from: date)
    }
}

@Model
final class FeelingItem {
    var feeling: String
    var symptom: String
    var recordedAt: Date
    var updatedAt: Date

    init(feeling: String, symptom: String, recordedAt: Date = Date()) {
        self.feeling = feeling
        self.symptom = symptom
        self.recordedAt = recordedAt
        self.updatedAt = recordedAt
    }

    var summary: String { "\(feeling) • อาการที่บันทึก: \(symptom)" }
}

@Model
final class AppointmentItem {
    var type: String
    var place: String
    var dateTime: Date
    var reminder: String
    var notificationIdentifier: String?
    var updatedAt: Date

    init(type: String, place: String, dateTime: Date = Date().addingTimeInterval(86400), reminder: String = "เตือนก่อน 1 วัน") {
        self.type = type
        self.place = place
        self.dateTime = dateTime
        self.reminder = reminder
        self.notificationIdentifier = nil
        self.updatedAt = Date()
    }

    var summary: String { "\(type) • \(place)" }
    var notificationStatusText: String {
        if reminder == "ไม่เตือน" { return "ไม่ตั้งแจ้งเตือน" }
        if notificationIdentifier != nil { return "ตั้งแจ้งเตือนแล้ว • \(reminder)" }
        return "ยังไม่ได้ตั้งแจ้งเตือน"
    }
}

@Model
final class SOSContactItem {
    var name: String
    var relationship: String
    var phone: String
    var isPrimary: Bool
    var updatedAt: Date

    init(name: String, relationship: String, phone: String, isPrimary: Bool = false) {
        self.name = name
        self.relationship = relationship
        self.phone = phone
        self.isPrimary = isPrimary
        self.updatedAt = Date()
    }

    var summary: String { "\(name) • \(relationship)" }
}

// MARK: - Design System

extension Color {
    static let appNavy = Color(red: 0.08, green: 0.18, blue: 0.32)
    static let appBlue = Color(red: 0.14, green: 0.48, blue: 0.83)
    static let appGreen = Color(red: 0.10, green: 0.55, blue: 0.36)
    static let appOrange = Color(red: 0.93, green: 0.52, blue: 0.15)
    static let appRed = Color(red: 0.82, green: 0.22, blue: 0.22)
    static let appGray = Color(red: 0.35, green: 0.39, blue: 0.45)
    static let appText = Color(red: 0.08, green: 0.12, blue: 0.18)
    static let appSubtext = Color(red: 0.32, green: 0.37, blue: 0.44)
    static let appSoftBackground = Color(red: 0.97, green: 0.97, blue: 0.95)

    static let medTint = Color(red: 1.00, green: 0.78, blue: 0.78)
    static let bpTint = Color(red: 0.75, green: 0.89, blue: 1.00)
    static let feelingTint = Color(red: 1.00, green: 0.86, blue: 0.62)
    static let calendarTint = Color(red: 0.76, green: 0.94, blue: 0.78)
    static let sosTint = Color(red: 1.00, green: 0.74, blue: 0.74)
    static let settingsTint = Color(red: 0.88, green: 0.90, blue: 0.94)
}

struct AppCard<Content: View>: View {
    let tint: Color
    let content: Content

    init(tint: Color = .white, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.black.opacity(0.12), lineWidth: 1.4))
            .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
            .foregroundStyle(Color.appText)
    }
}


struct HighlightCard<Content: View>: View {
    let tint: Color
    let accent: Color
    let content: Content

    init(tint: Color, accent: Color, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        content
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(accent.opacity(0.42), lineWidth: 2))
            .shadow(color: accent.opacity(0.18), radius: 10, x: 0, y: 5)
            .foregroundStyle(Color.appText)
    }
}

struct SummaryCard<Destination: View>: View {
    let icon: String
    let title: String
    let value: String
    let detail: String
    let tint: Color
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            AppCard(tint: tint) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(icon).font(.title2)
                        Text(title)
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(Color.appText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(Color.appSubtext)
                    }
                    Text(value)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color.appBlue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    Text(detail)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.appSubtext)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct HeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 30, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(subtitle)
                .font(.headline)
                .foregroundStyle(Color.appSubtext)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionTitle: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.appBlue)
                .frame(width: 8, height: 28)
            Text(text)
                .font(.title3.weight(.heavy))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct FormToggleButton: View {
    let title: String
    let isOpen: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isOpen ? "chevron.up.circle.fill" : "plus.circle.fill")
                .font(.title3.weight(.heavy))
            Text(title)
                .font(.headline.weight(.heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 56)
        .background(color)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: color.opacity(0.20), radius: 5, x: 0, y: 3)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 6, height: 34)
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3.weight(.heavy))
                Text(title)
                    .font(.headline.weight(.heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: color.opacity(0.22), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct InlineActionButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(tint.opacity(0.12))
                .foregroundStyle(tint)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ChoiceMenu: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selection)
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
        .padding(.vertical, 3)
    }
}

struct OtherTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.headline)
            .foregroundStyle(Color.appBlue)
            .tint(Color.appBlue)
            .textFieldStyle(.roundedBorder)
    }
}

struct ListRowCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appBlue.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.appBlue.opacity(0.55))
                    .frame(width: 7)
            }
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }
}

func shortTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "th_TH")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

func shortDateTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "th_TH")
    formatter.dateFormat = "d MMM HH:mm"
    return formatter.string(from: date)
}


func thaiFullDateTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "th_TH")
    formatter.calendar = Calendar(identifier: .buddhist)
    formatter.dateFormat = "EEEE d MMM yyyy HH:mm"
    return formatter.string(from: date)
}

func thaiShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "th_TH")
    formatter.calendar = Calendar(identifier: .buddhist)
    formatter.dateFormat = "EEEE d MMM yyyy"
    return formatter.string(from: date)
}

func todayText() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "th_TH")
    formatter.dateFormat = "EEEE d MMMM"
    return formatter.string(from: Date())
}

func last30DaysStart(from referenceDate: Date = Date()) -> Date {
    Calendar.current.date(byAdding: .day, value: -30, to: referenceDate) ?? referenceDate
}

func isWithinLast30Days(_ date: Date, from referenceDate: Date = Date()) -> Bool {
    date >= last30DaysStart(from: referenceDate)
}

func resetAppBadge() {
    UNUserNotificationCenter.current().setBadgeCount(0)
}


struct CompactCheckRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appGreen)
            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
