import Foundation

class DateUtil {
    
    fileprivate  static var calendar = Calendar.current
    
    enum DateFormat {
        case HHmmaddMMyyyy
        case yyyyMMddTHHmmssZ
        case yyyymmdd
        case HHmma
        case yyyyMMddTHHmmssssZ
        case yyyyMMddHHmmss
        case HHmm
        case HHmmss
        case dMMMMyyyy
        case MMMd
        
        var formatValue: String {
            switch self {
            case .HHmmaddMMyyyy: return "HH:mm a dd/MM/yyyy"
            case .yyyyMMddTHHmmssZ: return "yyyy-MM-dd'T'HH:mm:ss'Z'"
            case .yyyymmdd: return "yyyy-MM-dd"
            case .HHmma: return "hh:mm a"
            case .yyyyMMddTHHmmssssZ: return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            case .yyyyMMddHHmmss: return "yyyy-MM-dd HH:mm:ss"
            case .HHmm: return "HH:mm"
            case .HHmmss: return "HH:mm:ss"
            case .dMMMMyyyy: return "d MMM yyyy"
            case .MMMd: return "MMM d"
            }
        }
    }
    
    static var dateFormatter = DateFormatter()
    
    public static func calculateDateSinceAgo(_ date: Date) -> String {
        let dateComponents = calendar.dateComponents([.year,.month, .day], from: date)
        let currentDateComponents = calendar.dateComponents([.year,.month, .day], from: Date())
        let endComponents = DateComponents(year: dateComponents.year,month: dateComponents.month, day: dateComponents.day)
        let startComponents = DateComponents(year: currentDateComponents.year,month: currentDateComponents.month, day: currentDateComponents.day)
        let finalDateComponents = calendar.dateComponents([.year, .day], from: startComponents, to: endComponents)
        
        //        if finalDateComponents.description.contains("-") {
        if finalDateComponents.year == 0 && finalDateComponents.day ?? 0 < 0 {
            
            return String(format: "%@ days ago", arguments: ["\(finalDateComponents.day ?? 0)"]).replacingOccurrences(of: "-", with: "")
        } else if finalDateComponents.day == 0 && finalDateComponents.year ?? 0 < 0 {
            return String(format: "%@ years ago", arguments: ["\(finalDateComponents.year ?? 0)"]).replacingOccurrences(of: "-", with: "")
        } else if finalDateComponents.year == 0 && finalDateComponents.day == 0 {
            return "Today"
        } else {
            let year = "\(finalDateComponents.year ?? 0)"
            let day = "\(finalDateComponents.day ?? 0)"
            return "\(year) years \(day) days ago"
        }
    }
    
    static func convertResponseDateTime(dateTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Match your date format
        let date = dateFormatter.date(from: dateTime) ?? Date()
        let customDateFormatter = DateFormatter()
        customDateFormatter.dateFormat = "h:mm a"
        return customDateFormatter.string(from: date)
    }
    
    static func formatDateToLocal(from utcString: String,
                                  format: String = "dd MMMM 'at' hh:mma") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = formatter.date(from: utcString) else { return "" }
        // Output in local time zone
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    static func utcStringToLocalDate(utcString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        // Parse the UTC string to a Date object
        if let utcDate = dateFormatter.date(from: utcString) {
            return utcDate
        } else {
            return Date()
        }
    }
    
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: date1) == calendar.component(.year, from: date2) &&
        calendar.component(.month, from: date1) == calendar.component(.month, from: date2) &&
        calendar.component(.day, from: date1) == calendar.component(.day, from: date2)
    }
    
    static func convertUTCToLocal(_ utcDateString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        guard let date = formatter.date(from: utcDateString) else { return nil }
        // Convert to local
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d, yyyy h:mm a" // Customize as needed
        return formatter.string(from: date)
    }
    
    static func convertUTCToLocalAt(_ utcDateString: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        guard let date = isoFormatter.date(from: utcDateString) else { return nil }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .medium
        displayFormatter.timeZone = TimeZone.current
        displayFormatter.locale = Locale.current
        return displayFormatter.string(from: date)
    }
    
    static func utcStringToDate(utcString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        // Parse the UTC string to a Date object
        if let utcDate = dateFormatter.date(from: utcString) {
            return utcDate
        } else {
            return Date()
        }
    }
}
