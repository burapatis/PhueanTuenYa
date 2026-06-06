import Foundation

enum ExportFormatting {
    static func makeCSV(headers: [String], rows: [[String]]) -> String {
        ([headers] + rows).map { row in row.map(csvEscape).joined(separator: ",") }.joined(separator: "\n")
    }

    static func csvEscape(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
