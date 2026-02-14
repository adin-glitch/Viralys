import SwiftUI

// MARK: - Score Ring
/// Animated circular progress ring displaying the virality score
struct ScoreRing: View {
    let score: Int
    @State private var animatedProgress: CGFloat = 0
    @State private var showScore = false

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    DS.Colors.card,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )

            // Animated progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    DS.Colors.scoreGradient(for: score),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Score display
            VStack(spacing: DS.Spacing.xs) {
                Text("\(showScore ? score : 0)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(DS.Colors.scoreText(for: score))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.scoreColor(for: score))
            }
        }
        .frame(width: DS.Layout.scoreRingSize, height: DS.Layout.scoreRingSize)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).delay(0.3)) {
                animatedProgress = CGFloat(score) / 100.0
            }
            withAnimation(DS.Anim.spring.delay(0.5)) {
                showScore = true
            }
        }
    }
}

// MARK: - Mini Score Badge
/// Small score indicator used on thumbnails and list items
struct ScoreBadge: View {
    let score: Int
    var size: CGFloat = 36

    var body: some View {
        Text("\(score)")
            .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(DS.Colors.scoreColor(for: score))
            .clipShape(Circle())
            .shadow(color: DS.Colors.scoreColor(for: score).opacity(0.5), radius: 4, x: 0, y: 2)
    }
}
