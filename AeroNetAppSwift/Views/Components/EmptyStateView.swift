import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 50, weight: .light))
                .foregroundColor(Color.theme.textSecondary)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.theme.textPrimary)
                
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}
