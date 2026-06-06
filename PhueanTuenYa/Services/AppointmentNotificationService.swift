import UserNotifications

final class AppointmentNotificationService {
    private static let prefix = "appointment-reminder-"

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

    static func scheduleAppointmentReminder(for appointment: AppointmentItem, completion: @escaping (String) -> Void) {
        guard let offset = NotificationLogic.appointmentReminderOffsetSeconds(for: appointment.reminder) else {
            cancelAppointmentReminder(for: appointment)
            completion("ไม่ได้ตั้งแจ้งเตือน เพราะเลือกไม่เตือน")
            return
        }

        let triggerDate = appointment.dateTime.addingTimeInterval(-offset)
        guard triggerDate > Date().addingTimeInterval(5) else {
            cancelAppointmentReminder(for: appointment)
            completion("ยังไม่ได้ตั้งแจ้งเตือน เพราะเวลาเตือนผ่านไปแล้วหรือใกล้เกินไป")
            return
        }

        requestAuthorization { granted in
            guard granted else {
                completion("ยังไม่ได้อนุญาตการแจ้งเตือน หากเคยกดไม่อนุญาต ให้เปิด Settings ของ iPhone แล้วอนุญาตการแจ้งเตือนสำหรับแอปนี้")
                return
            }

            let identifier = appointment.notificationIdentifier ?? prefix + UUID().uuidString
            appointment.notificationIdentifier = identifier
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

            let content = UNMutableNotificationContent()
            content.title = "เพื่อนเตือนยา: นัดหมายสุขภาพ"
            content.body = "\(appointment.type) • \(appointment.place) • \(shortDateTime(appointment.dateTime))"
            content.sound = .default
            content.badge = 1

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error {
                        completion("ตั้งแจ้งเตือนนัดหมายไม่สำเร็จ: \(error.localizedDescription)")
                    } else {
                        completion("ตั้งแจ้งเตือนนัดหมาย \(appointment.type) • \(appointment.reminder) แล้ว")
                    }
                }
            }
        }
    }

    static func rescheduleAllAppointmentReminders(for appointments: [AppointmentItem], completion: @escaping (String) -> Void) {
        let targets = appointments.filter { $0.reminder != "ไม่เตือน" }
        guard !appointments.isEmpty else {
            completion("ยังไม่มีนัดหมายสุขภาพให้ตั้งแจ้งเตือน")
            return
        }
        guard !targets.isEmpty else {
            completion("มีนัดหมาย \(appointments.count) รายการ แต่ทั้งหมดเลือกไม่เตือน")
            return
        }

        var completedCount = 0
        var scheduledCount = 0

        for appointment in targets {
            scheduleAppointmentReminder(for: appointment) { message in
                completedCount += 1
                if message.contains("ตั้งแจ้งเตือนนัดหมาย") { scheduledCount += 1 }
                if completedCount == targets.count {
                    completion("ตรวจแล้ว ตั้งเตือนนัดหมายสำเร็จ \(scheduledCount) จาก \(targets.count) รายการ")
                }
            }
        }
    }

    static func cancelAppointmentReminder(for appointment: AppointmentItem) {
        if let identifier = appointment.notificationIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            appointment.notificationIdentifier = nil
        }
    }

    static func cancelAppointmentReminders(for appointments: [AppointmentItem]) {
        let identifiers = appointments.compactMap { $0.notificationIdentifier }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
