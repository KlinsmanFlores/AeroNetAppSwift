import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Colores basados en la nueva imagen (Deep Blue, Bright Teal, Light Blue)
    let background = Color(hex: "#09244A") // Azul profundo
    let backgroundGradientTop = Color(hex: "#051632")
    let backgroundGradientBottom = Color(hex: "#15447C")
    
    let accentGold = Color(hex: "#00D2A0") // En lugar de dorado, usamos el Bright Teal de la imagen
    
    let textPrimary = Color.white
    let textSecondary = Color(hex: "#8CB3D9") // Azul claro para subtítulos
    
    let surface = Color.white.opacity(0.1) // Glassmorphism claro
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
