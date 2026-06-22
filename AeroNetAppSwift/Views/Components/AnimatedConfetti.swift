import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var xOffset: CGFloat
    var yOffset: CGFloat
    var rotation: Double
    var speed: Double
}

struct AnimatedConfetti: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var animate = false
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Rectangle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * 1.5)
                    .rotationEffect(.degrees(animate ? particle.rotation * 3 : particle.rotation))
                    .position(
                        x: particle.xOffset,
                        y: animate ? UIScreen.main.bounds.height + 50 : particle.yOffset
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 3.5)) {
                animate = true
            }
        }
    }
    
    private func generateParticles() {
        var temp: [ConfettiParticle] = []
        let width = UIScreen.main.bounds.width
        
        for _ in 0..<120 {
            let p = ConfettiParticle(
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 8...16),
                xOffset: CGFloat.random(in: 0...width),
                yOffset: CGFloat.random(in: -200...(-20)),
                rotation: Double.random(in: 0...360),
                speed: Double.random(in: 1.5...4.0)
            )
            temp.append(p)
        }
        self.particles = temp
    }
}
