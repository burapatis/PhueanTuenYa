import SwiftData
import UIKit

func saveContext(_ context: ModelContext) {
    do { try context.save() } catch { print("SwiftData save error: \(error)") }
}

func makeTimeDate(hour: Int, minute: Int) -> Date {
    Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
}

func dateFromTimeText(_ text: String) -> Date {
    let parts = text.split(separator: ":").compactMap { Int($0) }
    guard parts.count >= 2 else { return makeTimeDate(hour: 8, minute: 0) }
    return makeTimeDate(hour: parts[0], minute: parts[1])
}

func timeOnlyText(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "th_TH")
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}


extension String {
    func height(constrainedTo width: CGFloat, font: UIFont) -> CGFloat {
        let rect = self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return ceil(rect.height)
    }
}
