import UserNotifications

final class MedicationNotificationService {
    private static let prefix = "medication-reminder-"

    private static func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(true) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func scheduleMedicationReminder(for medication: MedicationItem, completion: @escaping (String) -> Void) {
        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }

            let identifier = medication.notificationIdentifier ?? prefix + UUID().uuidString
            medication.notificationIdentifier = identifier

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

            let content = UNMutableNotificationContent()
            content.title = "เพื่อนเตือนยา"
            content.body = "ถึงเวลา \(medication.name) • \(medication.dosage) • \(medication.instruction)"
            content.sound = .default
            content.badge = 1

            let time = NotificationLogic.medicationTimeComponents(from: medication.timeText)
            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error {
                        completion("ตั้งแจ้งเตือนไม่สำเร็จ: \(error.localizedDescription)")
                    } else {
                        completion("ตั้งแจ้งเตือนยา \(medication.name) เวลา \(medication.timeText) น. แล้ว")
                    }
                }
            }
        }
    }

    static func rescheduleAllMedicationReminders(for medications: [MedicationItem], completion: @escaping (String) -> Void) {
        guard !medications.isEmpty else {
            completion("ยังไม่มีรายการยาให้ตั้งแจ้งเตือน")
            return
        }

        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }

            var scheduledCount = 0
            let group = DispatchGroup()

            for medication in medications {
                group.enter()
                scheduleMedicationReminder(for: medication) { _ in
                    scheduledCount += 1
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion("ตรวจแล้ว ตั้งเตือนยาสำเร็จ \(scheduledCount) จาก \(medications.count) รายการ")
            }
        }
    }

    static func cancelMedicationReminder(for medication: MedicationItem) {
        if let identifier = medication.notificationIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            medication.notificationIdentifier = nil
        }
    }

    static func cancelMedicationReminders(for medications: [MedicationItem]) {
        let identifiers = medications.compactMap { $0.notificationIdentifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    static func scheduleSnoozeReminder(medicationName: String, dosage: String, instruction: String, completion: @escaping (String) -> Void) {
        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "เพื่อนเตือนยา"
            let detail = [medicationName, dosage, instruction].filter { !$0.isEmpty }.joined(separator: " • ")
            content.body = "เตือนอีกครั้ง: \(detail)"
            content.sound = .default
            content.badge = 1

            let identifier = "medication-snooze-" + UUID().uuidString
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: NotificationLogic.snoozeIntervalSeconds, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error {
                        completion("ตั้งเตือนอีก 10 นาทีไม่สำเร็จ: \(error.localizedDescription)")
                    } else {
                        completion("บันทึกสถานะ ‘เตือนอีก 10 นาที’ แล้ว และจะแจ้งเตือน \(medicationName) อีกครั้งใน 10 นาที")
                    }
                }
            }
        }
    }

    static func scheduleTestNotification(completion: @escaping (String) -> Void) {
        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }
            let content = UNMutableNotificationContent()
            content.title = "เพื่อนเตือนยา"
            content.body = "นี่คือการทดสอบการแจ้งเตือน หากเห็นข้อความนี้ แปลว่าระบบแจ้งเตือนทำงาน"
            content.sound = .default
            let req = UNNotificationRequest(identifier: "test-" + UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false))
            UNUserNotificationCenter.current().add(req) { _ in
                DispatchQueue.main.async { completion("ตั้งการทดสอบแจ้งเตือนแล้ว กรุณารอประมาณ 5 วินาที หากเห็น banner แปลว่าระบบแจ้งเตือนทำงาน") }
            }
        }
    }
}
