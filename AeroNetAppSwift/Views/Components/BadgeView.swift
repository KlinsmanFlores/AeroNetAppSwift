import SwiftUI

struct BadgeView: View {
    let text: String
    let status: String // active, pending, suspended, paid, overdue, etc.
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(foregroundColor.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var backgroundColor: Color {
        switch status.lowercased() {
        case "active", "paid", "resolved", "success":
            return Color.theme.success
        case "pending", "in_progress", "warning":
            return Color.theme.warning
        case "suspended", "overdue", "closed", "danger", "error":
            return Color.theme.danger
        default:
            return Color.theme.textSecondary
        }
    }
    
    private var foregroundColor: Color {
        switch status.lowercased() {
        case "active", "paid", "resolved", "success":
            return Color.theme.success
        case "pending", "in_progress", "warning":
            return Color.theme.warning
        case "suspended", "overdue", "closed", "danger", "error":
            return Color.theme.danger
        default:
            return Color.theme.textSecondary
        }
    }
}
