import SwiftUI

// MARK: - Premium Banner
/// Fixed bottom banner promoting premium upgrade
struct PremiumBanner: View {
    let onUpgrade: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Crown icon
            Image(systemName: "crown.fill")
                .font(.system(size: 24))
                .foregroundColor(DS.Colors.warning)

            VStack(alignment: .leading, spacing: 2) {
                Text("Unlock unlimited uploads")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                Text("& comparisons")
                    .font(.system(size: 12))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            // Try Premium button
            Button(action: {
                HapticManager.impact()
                onUpgrade()
            }) {
                Text("Try Premium")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(DS.Colors.accent)
                    .cornerRadius(DS.Radius.xl)
            }

            // Dismiss
            Button(action: {
                HapticManager.selection()
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DS.Colors.textSecondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(DS.Spacing.md)
        .background(
            DS.Colors.card
                .overlay(DS.Colors.primaryGradient.opacity(0.15))
        )
        .cornerRadius(DS.Radius.lg)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.bottom, DS.Spacing.sm)
        .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: -5)
    }
}

// MARK: - Premium Feature Card
/// Card shown for locked premium features
struct PremiumFeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            Text(icon)
                .font(.system(size: 28))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardElevated)
        .cornerRadius(DS.Radius.md)
    }
}

// MARK: - Free Tier Card
struct FreeTierCard: View {
    let remaining: Int
    let onUpgrade: () -> Void

    var body: some View {
        HStack(spacing: DS.Spacing.md) {
            // Badge
            ZStack {
                Circle()
                    .fill(DS.Colors.accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("FREE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(DS.Colors.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(DS.Colors.accent.opacity(0.15))
                    .cornerRadius(4)

                Text("\(remaining) uploads remaining today")
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            TextButton("Upgrade", action: onUpgrade)
        }
        .padding(DS.Spacing.md)
        .cardStyle()
    }
}
