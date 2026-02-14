import SwiftUI

// MARK: - Optimized Text Card
/// Gradient-bordered card showing optimized text with copy-to-clipboard
struct OptimizedTextCard: View {
    let optimizedText: String
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Colors.primaryGradient)

                Text("Optimized Post")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DS.Colors.textPrimary)

                Spacer()

                // Copy button
                Button {
                    UIPasteboard.general.string = optimizedText
                    HapticManager.success()
                    withAnimation(DS.Anim.quick) {
                        copied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(DS.Anim.quick) {
                            copied = false
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 13, weight: .semibold))
                        Text(copied ? "Copied!" : "Copy")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(copied ? DS.Colors.success : DS.Colors.accent)
                    .padding(.horizontal, DS.Spacing.sm + 2)
                    .padding(.vertical, DS.Spacing.xs + 2)
                    .background((copied ? DS.Colors.success : DS.Colors.accent).opacity(0.15))
                    .cornerRadius(DS.Radius.sm)
                }
            }

            // Optimized text content
            Text(optimizedText)
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardElevated)
        .cornerRadius(DS.Radius.lg)
        .gradientBorder(lineWidth: 1.5)
    }
}
