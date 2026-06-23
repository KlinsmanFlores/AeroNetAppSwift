import SwiftUI

// MARK: - Glass Card Modifier (Glassmorphism - Semana 9)
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.theme.cardBackground)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.black.opacity(0.8))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.theme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Shimmer Loading Effect (Semana 14)
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(gradient: Gradient(colors: [.clear, Color.white.opacity(0.3), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * geo.size.width * 1.6 - geo.size.width * 0.3)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Animated Button Style (Semana 14)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Primary Button Modifier
struct PrimaryButtonModifier: ViewModifier {
    var isDisabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isDisabled ? [Color.gray] : [Color.theme.accent, Color.theme.accentLight]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(Color.theme.background)
            .cornerRadius(14)
    }
}

extension View {
    func primaryButton(isDisabled: Bool = false) -> some View {
        modifier(PrimaryButtonModifier(isDisabled: isDisabled))
    }
}

// MARK: - Card Section Header
struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color.theme.textSecondary)
            .textCase(.uppercase)
    }
}

extension View {
    func sectionHeader() -> some View {
        modifier(SectionHeaderModifier())
    }
}
