import Foundation

enum NotificationLogic {
    static let snoozeIntervalSeconds: TimeInterval = 600

    static func appointmentReminderOffsetSeconds(for reminder: String) -> TimeInterval? {
        switch reminder {
        case "เตือนก่อน 1 ชั่วโมง": return 60 * 60
        case "เตือนก่อน 1 วัน": return 24 * 60 * 60
        case "เตือนก่อน 3 วัน": return 3 * 24 * 60 * 60
        default: return nil
        }
    }

    static func medicationTimeComponents(from timeText: String) -> (hour: Int, minute: Int) {
        let parts = timeText.split(separator: ":").compactMap { Int($0) }
        return (parts.count > 0 ? parts[0] : 8, parts.count > 1 ? parts[1] : 0)
    }
}
