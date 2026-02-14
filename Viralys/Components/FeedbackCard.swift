import SwiftUI

// MARK: - Feedback Card
/// Shows actionable improvement suggestion for a low-scoring category
struct FeedbackCard: View {
    let category: String
    let icon: String
    let score: Int
    let suggestions: [String]
    let index: Int

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(DS.Colors.scoreColor(for: score * 10))

                Text("\(category) (\(score)/10)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DS.Colors.textPrimary)

                Spacer()

                // Severity indicator
                Text(score < 4 ? "Critical" : "Improve")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(score < 4 ? DS.Colors.error : DS.Colors.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((score < 4 ? DS.Colors.error : DS.Colors.warning).opacity(0.15))
                    .cornerRadius(DS.Radius.sm)
            }

            // Suggestions list
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                ForEach(suggestions.prefix(3), id: \.self) { tip in
                    HStack(alignment: .top, spacing: DS.Spacing.sm) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 13))
                            .foregroundColor(DS.Colors.success)
                            .padding(.top, 2)

                        Text(tip)
                            .font(.system(size: 14))
                            .foregroundColor(DS.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardElevated)
        .cornerRadius(DS.Radius.md)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .onAppear {
            withAnimation(DS.Anim.spring.delay(Double(index) * 0.1 + 0.3)) {
                appeared = true
            }
        }
    }
}

// MARK: - Caption Card
/// Shows a generated caption suggestion the user can copy
struct CaptionCard: View {
    let caption: String

    var body: some View {
        HStack {
            Text(caption)
                .font(.system(size: 14))
                .foregroundColor(DS.Colors.textPrimary)
                .lineLimit(2)

            Spacer()

            Image(systemName: "doc.on.doc")
                .font(.system(size: 13))
                .foregroundColor(DS.Colors.accent)
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardElevated)
        .cornerRadius(DS.Radius.sm)
        .onTapGesture {
            UIPasteboard.general.string = caption
            HapticManager.success()
        }
    }
}
