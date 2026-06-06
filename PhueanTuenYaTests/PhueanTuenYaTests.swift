import XCTest
@testable import PhueanTuenYa

final class PhueanTuenYaTests: XCTestCase {
    func testIsWithinLast30DaysIncludesRecentDate() {
        let recent = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        XCTAssertTrue(isWithinLast30Days(recent))
    }

    func testIsWithinLast30DaysExcludesOldDate() {
        let old = Calendar.current.date(byAdding: .day, value: -31, to: Date())!
        XCTAssertFalse(isWithinLast30Days(old))
    }

    func testCSVFormattingEscapesQuotesAndCommas() {
        let csv = ExportFormatting.makeCSV(
            headers: ["ชื่อ", "รายละเอียด"],
            rows: [["ยา A", "1 เม็ด, \"หลังอาหาร\""]]
        )
        XCTAssertTrue(csv.contains("\"1 เม็ด, \"\"หลังอาหาร\"\"\""))
        XCTAssertTrue(csv.hasPrefix("\"ชื่อ\",\"รายละเอียด\""))
    }

    func testAppointmentReminderOffsets() {
        XCTAssertEqual(NotificationLogic.appointmentReminderOffsetSeconds(for: "เตือนก่อน 1 ชั่วโมง"), 3600)
        XCTAssertEqual(NotificationLogic.appointmentReminderOffsetSeconds(for: "เตือนก่อน 1 วัน"), 86400)
        XCTAssertEqual(NotificationLogic.appointmentReminderOffsetSeconds(for: "เตือนก่อน 3 วัน"), 259200)
        XCTAssertNil(NotificationLogic.appointmentReminderOffsetSeconds(for: "ไม่เตือน"))
    }

    func testMedicationTimeComponentsParsesTimeText() {
        let parsed = NotificationLogic.medicationTimeComponents(from: "08:30")
        XCTAssertEqual(parsed.hour, 8)
        XCTAssertEqual(parsed.minute, 30)

        let fallback = NotificationLogic.medicationTimeComponents(from: "invalid")
        XCTAssertEqual(fallback.hour, 8)
        XCTAssertEqual(fallback.minute, 0)
    }

    func testSnoozeIntervalIsTenMinutes() {
        XCTAssertEqual(NotificationLogic.snoozeIntervalSeconds, 600)
    }
}
