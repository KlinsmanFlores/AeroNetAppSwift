import SwiftUI

// MARK: - Color Theme Extension
extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Fondos principales
    let background = Color(hex: "#09244A")
    let backgroundGradientTop = Color(hex: "#051632")
    let backgroundGradientBottom = Color(hex: "#15447C")
    let surfaceDark = Color(hex: "#0D2B52")
    
    // Acento principal (Teal brillante)
    let accent = Color(hex: "#00D2A0")
    let accentGold = Color(hex: "#00D2A0")
    let accentLight = Color(hex: "#00E5B0")
    
    // Texto
    let textPrimary = Color.white
    let textSecondary = Color(hex: "#8CB3D9")
    let textMuted = Color(hex: "#5A7DA0")
    
    // Superficies glass
    let surface = Color.white.opacity(0.1)
    let surfaceLight = Color.white.opacity(0.05)
    let glassBorder = Color.white.opacity(0.15)
    
    // Estados / Badges
    let success = Color(hex: "#10B981")
    let successBg = Color(hex: "#10B981").opacity(0.2)
    let warning = Color(hex: "#F59E0B")
    let warningBg = Color(hex: "#F59E0B").opacity(0.2)
    let danger = Color(hex: "#EF4444")
    let dangerBg = Color(hex: "#EF4444").opacity(0.2)
    let info = Color(hex: "#6366F1")
    let infoBg = Color(hex: "#6366F1").opacity(0.2)
    
    // Cards
    let cardBackground = Color.white.opacity(0.08)
    let cardBorder = Color.white.opacity(0.12)
    
    // Tab bar
    let tabBarBg = Color(hex: "#061E3C")
}

// MARK: - Hex Color Init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
