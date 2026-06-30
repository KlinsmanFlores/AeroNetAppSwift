import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        GlassCard {
            // 🚀 SOLUCIÓN DE ARQUITECTURA VISUAL: Pasamos a un VStack para dar holgura total al texto
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    // El icono se sitúa arriba a la derecha, liberando espacio para el texto
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Título dinámico: Evita saltos letra por letra reduciendo la fuente elásticamente si el espacio es crítico
                    Text(title)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    // Valor dinámico
                    Text(value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
