import Foundation

extension Double {
    
    func format(f: String) -> String { return String(format: "%\(f)f", self) as String }
    
    func toString() -> String { return String(format: "%.1f",self) }
    
    func timeValueInHoursMinutesSeconds() -> String {
        let time = TimeInterval(self)
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        // return formated string
        if hour > 0 {
            return String(format: "%02i:%02i:%02i", hour, minute, second)
        } else {
            // return formated string
            return String(format: "%02i:%02i", minute, second)
        }
    }
    
    /// Rounds the double to decimal places value
    func roundToPlace(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
