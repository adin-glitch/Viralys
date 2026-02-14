import SwiftUI

// MARK: - Benchmark Comparison View
/// Shows how the user's video compares to a "typical viral video" benchmark
struct BenchmarkView: View {
    let result: AnalysisResult
    @State private var appeared = false

    // Viral benchmark targets
    private let viralHook = 9
    private let viralPacing = 9
    private let viralLength = 10
    private let viralQuality = 8
    private let viralOverall = 85

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 18))
                    .foregroundStyle(DS.Colors.primaryGradient)

                Text("Viral Benchmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DS.Colors.textPrimary)
            }

            // Overall comparison
            HStack(spacing: DS.Spacing.xl) {
                scoreColumn(label: "Your Video", score: result.score, color: DS.Colors.scoreColor(for: result.score))
                scoreColumn(label: "Viral Average", score: viralOverall, color: DS.Colors.success)
            }
            .padding(.vertical, DS.Spacing.sm)

            // Category gaps
            VStack(spacing: DS.Spacing.sm) {
                gapRow("Hook", yours: result.hookScore, viral: viralHook)
                gapRow("Pacing", yours: result.pacingScore, viral: viralPacing)
                gapRow("Length", yours: result.lengthScore, viral: viralLength)
                gapRow("Quality", yours: result.qualityScore, viral: viralQuality)
            }

            // Focus recommendation
            if let biggest = biggestGap {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "target")
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.accent)

                    Text("Focus on improving **\(biggest.0)** to close the gap")
                        .font(.system(size: 13))
                        .foregroundColor(DS.Colors.textSecondary)
                }
                .padding(DS.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DS.Colors.accent.opacity(0.08))
                .cornerRadius(DS.Radius.sm)
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DS.Anim.spring.delay(0.5)) {
                appeared = true
            }
        }
    }

    // MARK: - Score Column
    private func scoreColumn(label: String, score: Int, color: Color) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text("\(score)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(DS.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Gap Row
    private func gapRow(_ label: String, yours: Int, viral: Int) -> some View {
        let gap = viral - yours
        return HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(DS.Colors.textSecondary)
                .frame(width: 60, alignment: .leading)

            // Your score
            Text("\(yours)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(DS.Colors.scoreColor(for: yours * 10))
                .frame(width: 24)

            // Bar comparison
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DS.Colors.card)
                        .frame(height: 6)

                    // Your bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DS.Colors.scoreColor(for: yours * 10))
                        .frame(width: geo.size.width * CGFloat(yours) / 10.0, height: 6)

                    // Viral marker
                    RoundedRectangle(cornerRadius: 1)
                        .fill(DS.Colors.success.opacity(0.5))
                        .frame(width: 2, height: 10)
                        .offset(x: geo.size.width * CGFloat(viral) / 10.0 - 1)
                }
            }
            .frame(height: 10)

            // Gap
            Text(gap > 0 ? "-\(gap)" : "+\(abs(gap))")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(gap > 0 ? DS.Colors.error : DS.Colors.success)
                .frame(width: 28, alignment: .trailing)
        }
    }

    // MARK: - Biggest Gap
    private var biggestGap: (String, Int)? {
        let gaps = [
            ("Hook Strength", viralHook - result.hookScore),
            ("Pacing", viralPacing - result.pacingScore),
            ("Video Length", viralLength - result.lengthScore),
            ("Quality", viralQuality - result.qualityScore)
        ].filter { $0.1 > 0 }
        return gaps.max(by: { $0.1 < $1.1 })
    }
}
