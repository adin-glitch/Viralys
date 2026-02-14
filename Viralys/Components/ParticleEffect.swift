import SwiftUI

// MARK: - Particle Effect
/// Subtle sparkle particles for score reveal animations
struct ParticleEffect: View {
    let color: Color
    let count: Int

    @State private var particles: [Particle] = []
    @State private var isAnimating = false

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var rotation: Double
    }

    init(color: Color = DS.Colors.accent, count: Int = 20) {
        self.color = color
        self.count = count
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundColor(color)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
                withAnimation(Animation.easeOut(duration: 2.0)) {
                    isAnimating = true
                }
                animateParticles(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<count).map { _ in
            Particle(
                x: size.width / 2 + CGFloat.random(in: -30...30),
                y: size.height / 2 + CGFloat.random(in: -30...30),
                scale: CGFloat.random(in: 0.3...1.0),
                opacity: 1.0,
                rotation: Double.random(in: 0...360)
            )
        }
    }

    private func animateParticles(in size: CGSize) {
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            withAnimation(Animation.easeOut(duration: Double.random(in: 1.5...2.5)).delay(delay)) {
                particles[i].x += CGFloat.random(in: -100...100)
                particles[i].y += CGFloat.random(in: -100...100)
                particles[i].scale = 0
                particles[i].opacity = 0
                particles[i].rotation += Double.random(in: -180...180)
            }
        }
    }
}

// MARK: - Animated Sparkle
/// Single animated sparkle for decorative use
struct AnimatedSparkle: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    let delay: Double

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 12))
            .foregroundColor(DS.Colors.accent)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    opacity = 1
                    scale = 1.2
                }
            }
    }
}
