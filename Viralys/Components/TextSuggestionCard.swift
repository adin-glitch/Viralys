import SwiftUI

// MARK: - Text Suggestion Card
/// Individual suggestion card with category, icon, and priority badge
struct TextSuggestionCard: View {
    let suggestion: TextSuggestion
    let index: Int

    @State private var appeared = false

    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.md) {
            // Icon
            Image(systemName: suggestion.icon)
                .font(.system(size: 18))
                .foregroundStyle(DS.Colors.primaryGradient)
                .frame(width: 36, height: 36)
                .background(DS.Colors.primaryPurple.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                // Category + priority
                HStack {
                    Text(suggestion.category)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(DS.Colors.textPrimary)

                    Spacer()

                    // Priority badge
                    Text(suggestion.priority.label)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: suggestion.priority.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: suggestion.priority.color).opacity(0.15))
                        .cornerRadius(DS.Radius.sm)
                }

                // Suggestion text
                Text(suggestion.text)
                    .font(.system(size: 14))
                    .foregroundColor(DS.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
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
