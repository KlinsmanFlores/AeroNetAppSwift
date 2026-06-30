import SwiftUI

// MARK: - Color Theme Extension
extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Fondos principales (Inspirados en la imagen Pinterest)
    let background = Color(hex: "#0055FF")
    let backgroundGradientTop = Color(hex: "#00D2FF") // Cyan vibrante brillante
    let backgroundGradientBottom = Color(hex: "#002B99") // Azul oscuro profundo
    let surfaceDark = Color.white.opacity(0.15)
    
    // Acento principal (Blanco para resaltar sobre el azul)
    let accent = Color.white
    let accentGold = Color.white
    let accentLight = Color.white.opacity(0.9)
    
    // 🚀 RETOQUE DE CONTRASTE: Eliminamos la transparencia excesiva para que las letras se lean oscuras o sólidas
    let textPrimary = Color.black
    let textSecondary = Color.black // 💡 Texto secundario sólido al 100% para leer fechas y métodos sin esfuerzo
    let textMuted = Color.black.opacity(0.85) // 💡 Modificado de 0.65 a 0.85 para alto contraste legible
    
    // Superficies glass
    let surface = Color.white.opacity(0.25)
    let surfaceLight = Color.white.opacity(0.15)
    let glassBorder = Color.white.opacity(0.4)
    
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
    let cardBackground = Color.white.opacity(0.15)
    let cardBorder = Color.white.opacity(0.3)
    
    // Tab bar
    let tabBarBg = Color(hex: "#001A66")
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
