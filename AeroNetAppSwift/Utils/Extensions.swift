import Foundation

// MARK: - Date Formatting
extension Date {
    func formatted(as format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: self)
    }
    
    static func fromISO(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) { return date }
        // Fallback sin fracciones
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: string) { return date }
        // Fallback solo fecha
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: string)
    }
}

// MARK: - Currency Formatting
extension Double {
    var currencyPEN: String {
        return String(format: "S/ %.2f", self)
    }
}

extension Int {
    var currencyPEN: String {
        return Double(self).currencyPEN
    }
}

// MARK: - String Validation
extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    var isValidDNI: Bool {
        return self.count == 8 && self.allSatisfy { $0.isNumber }
    }
    
    var isValidRUC: Bool {
        return self.count == 11 && self.allSatisfy { $0.isNumber }
    }
    
    var isValidPhone: Bool {
        let digits = self.filter { $0.isNumber }
        return digits.count >= 9 && digits.count <= 15
    }
}
