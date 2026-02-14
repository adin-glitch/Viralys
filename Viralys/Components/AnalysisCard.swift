import SwiftUI

// MARK: - Analysis Breakdown Card
/// Displays a single score factor with bar visualization
struct AnalysisCard: View {
    let icon: String
    let title: String
    let score: Int       // 0-10
    let description: String
    let index: Int

    @State private var appeared = false

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(DS.Colors.scoreColor(for: score * 10))
                .frame(width: 44, height: 44)
                .background(DS.Colors.scoreColor(for: score * 10).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                // Title and score
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DS.Colors.textPrimary)

                    Spacer()

                    Text("\(score)/10")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(DS.Colors.scoreColor(for: score * 10))
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DS.Colors.card)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(DS.Colors.scoreGradient(for: score * 10))
                            .frame(width: appeared ? geo.size.width * CGFloat(score) / 10.0 : 0, height: 6)
                    }
                }
                .frame(height: 6)

                // Description
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(DS.Spacing.md)
        .cardStyle()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(DS.Anim.spring.delay(Double(index) * 0.1 + 0.5)) {
                appeared = true
            }
        }
    }
}

// MARK: - Recent Analysis Card (Horizontal Scroll)
struct RecentAnalysisCard: View {
    let result: AnalysisResult

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Thumbnail with score badge
            ZStack(alignment: .topTrailing) {
                if let data = result.thumbnailData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: DS.Layout.thumbnailSize, height: DS.Layout.thumbnailSize)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
                } else {
                    RoundedRectangle(cornerRadius: DS.Radius.md)
                        .fill(DS.Colors.cardElevated)
                        .frame(width: DS.Layout.thumbnailSize, height: DS.Layout.thumbnailSize)
                        .overlay(
                            Image(systemName: "video.fill")
                                .foregroundColor(DS.Colors.textSecondary)
                        )
                }

                ScoreBadge(score: result.score, size: 28)
                    .offset(x: 4, y: -4)
            }

            // Date
            Text(result.date.shortDisplay)
                .font(.system(size: 11))
                .foregroundColor(DS.Colors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: DS.Layout.thumbnailSize)
    }
}
