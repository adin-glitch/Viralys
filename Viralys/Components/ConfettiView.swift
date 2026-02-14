import SwiftUI

// MARK: - Confetti View
/// Celebration animation for high scores (>85)
struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []
    @State private var isActive = false

    let colors: [Color] = [
        DS.Colors.primaryPurple,
        DS.Colors.primaryBlue,
        DS.Colors.accent,
        DS.Colors.success,
        DS.Colors.warning,
        .white
    ]

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var scale: CGFloat
        var color: Color
        var shape: ConfettiShape

        enum ConfettiShape: CaseIterable {
            case circle, rectangle, triangle
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(confetti) { piece in
                    confettiShape(piece)
                        .foregroundColor(piece.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(piece.scale)
                        .rotationEffect(.degrees(piece.rotation))
                        .position(x: piece.x, y: piece.y)
                }
            }
            .onAppear {
                launchConfetti(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func confettiShape(_ piece: ConfettiPiece) -> some View {
        switch piece.shape {
        case .circle:
            Circle().fill(piece.color)
        case .rectangle:
            Rectangle().fill(piece.color)
                .frame(width: 6, height: 10)
        case .triangle:
            Triangle().fill(piece.color)
                .frame(width: 8, height: 8)
        }
    }

    private func launchConfetti(in size: CGSize) {
        // Create initial confetti pieces at top
        confetti = (0..<40).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2),
                color: colors.randomElement() ?? .white,
                shape: ConfettiPiece.ConfettiShape.allCases.randomElement() ?? .circle
            )
        }

        // Animate falling
        for i in confetti.indices {
            let duration = Double.random(in: 2.0...3.5)
            let delay = Double.random(in: 0...0.8)
            withAnimation(Animation.easeIn(duration: duration).delay(delay)) {
                confetti[i].y = size.height + 50
                confetti[i].x += CGFloat.random(in: -80...80)
                confetti[i].rotation += Double.random(in: 360...1080)
            }
            // Fade out near end
            withAnimation(Animation.easeIn(duration: 0.5).delay(delay + duration - 0.5)) {
                confetti[i].scale = 0
            }
        }
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
