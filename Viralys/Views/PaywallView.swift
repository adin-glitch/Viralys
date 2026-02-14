import SwiftUI

// MARK: - Paywall View
/// Premium subscription modal with features list and pricing
struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var appeared = false

    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("infinity", "Unlimited Uploads", "Analyze as many videos as you want"),
        ("arrow.left.arrow.right", "Compare with Viral Videos", "Side-by-side analysis with top performers"),
        ("brain.head.profile", "Detailed AI Feedback", "Specific tips to improve your content"),
        ("bolt.fill", "Hook Analyzer", "Frame-by-frame breakdown of your opening"),
        ("chart.bar.fill", "Export Reports", "Share insights with your team")
    ]

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Spacing.lg) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.selection()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(DS.Colors.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(DS.Colors.card)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.md)

                    // Header
                    headerSection

                    // Features list
                    featuresSection

                    // Pricing card
                    pricingCard

                    // Action buttons
                    actionButtons

                    Spacer().frame(height: DS.Spacing.xl)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DS.Anim.spring) {
                appeared = true
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: DS.Spacing.md) {
            // Crown with glow
            ZStack {
                Circle()
                    .fill(DS.Colors.warning.opacity(0.15))
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(DS.Colors.warning.opacity(0.08))
                    .frame(width: 140, height: 140)

                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundColor(DS.Colors.warning)
            }

            Text("Viralys Premium")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)

            Text("Take your content to the next level")
                .font(.system(size: 17))
                .foregroundColor(DS.Colors.textSecondary)
        }
        .padding(.top, DS.Spacing.md)
    }

    // MARK: - Features
    private var featuresSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            ForEach(features.indices, id: \.self) { index in
                featureRow(features[index])
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(DS.Anim.spring.delay(Double(index) * 0.08), value: appeared)
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    private func featureRow(_ feature: (icon: String, title: String, subtitle: String)) -> some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: feature.icon)
                .font(.system(size: 20))
                .foregroundStyle(DS.Colors.primaryGradient)
                .frame(width: 44, height: 44)
                .background(DS.Colors.primaryPurple.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
                Text(feature.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.cardElevated)
        .cornerRadius(DS.Radius.md)
    }

    // MARK: - Pricing Card
    private var pricingCard: some View {
        VStack(spacing: DS.Spacing.md) {
            // Trial badge
            Text("7-day free trial")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.xs)
                .background(DS.Colors.accent)
                .cornerRadius(DS.Radius.xl)

            // Price
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("$7.99")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(DS.Colors.textPrimary)
                Text("/month")
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Text("Cancel anytime")
                .font(.system(size: 13))
                .foregroundColor(DS.Colors.textSecondary)
        }
        .padding(DS.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(DS.Colors.primaryGradient.opacity(0.15))
        .cornerRadius(DS.Radius.lg)
        .gradientBorder(lineWidth: 1.5)
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: DS.Spacing.md) {
            GradientButton("Start Free Trial", icon: "crown.fill") {
                // Placeholder - RevenueCat integration later
                HapticManager.success()
                appState.isPremium = true
                dismiss()
            }

            GradientButton("Subscribe Now", style: .secondary) {
                HapticManager.success()
                appState.isPremium = true
                dismiss()
            }

            TextButton("Restore Purchase") {
                // Placeholder for restore
                HapticManager.selection()
            }

            TextButton("Maybe Later", color: DS.Colors.textSecondary) {
                dismiss()
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
    }
}
