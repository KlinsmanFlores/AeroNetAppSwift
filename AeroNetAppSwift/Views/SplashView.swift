import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = -45
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            // Fondo degradado Dark Teal Premium
            LinearGradient(gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo AeroNet Animado (Semana 14)
                ZStack {
                    Circle()
                        .fill(Color.theme.accent.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.0 : 1.0)
                    
                    Circle()
                        .fill(Color.theme.accent)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "wifi")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color.theme.backgroundGradientBottom)
                }
                
                Text("AERONET")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)
                    .kerning(4)
                
                Text("Internet Satelital & Fibra Óptica")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                    .kerning(1)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    self.scale = 1.0
                    self.opacity = 1.0
                }
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.rotation = 0
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
