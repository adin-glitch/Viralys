import SwiftUI

// MARK: - Compare View
/// Locked placeholder screen for the premium Compare feature
struct CompareView: View {
    @EnvironmentObject var appState: AppState
    @State private var tiktokURL: String = ""
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            VStack(spacing: DS.Spacing.lg) {
                // Navigation title area
                Text("Compare Videos")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(DS.Colors.textPrimary)
                    .padding(.top, DS.Spacing.xl)

                // Content (blurred for non-premium)
                ZStack {
                    VStack(spacing: DS.Spacing.lg) {
                        // URL input
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            Text("Paste TikTok URL")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(DS.Colors.textSecondary)

                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(DS.Colors.textSecondary)
                                TextField("", text: $tiktokURL)
                                    .placeholder(when: tiktokURL.isEmpty) {
                                        Text("https://tiktok.com/...")
                                            .foregroundColor(DS.Colors.textSecondary.opacity(0.5))
                                    }
                                    .foregroundColor(DS.Colors.textPrimary)
                                    .disabled(!appState.isPremium)
                            }
                            .padding(DS.Spacing.md)
                            .background(DS.Colors.cardElevated)
                            .cornerRadius(DS.Radius.md)
                        }
                        .padding(.horizontal, DS.Spacing.lg)

                        // Compare button
                        GradientButton("Compare", icon: "arrow.left.arrow.right") {
                            // Placeholder
                        }
                        .padding(.horizontal, DS.Spacing.lg)
                        .opacity(0.5)

                        // Comparison preview placeholder
                        HStack(spacing: DS.Spacing.md) {
                            comparisonPlaceholder("Your Video")
                            comparisonPlaceholder("Viral Video")
                        }
                        .padding(.horizontal, DS.Spacing.lg)

                        Spacer()
                    }

                    // Lock overlay for non-premium
                    if !appState.isPremium {
                        lockOverlay
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
    }

    // MARK: - Comparison Placeholder
    private func comparisonPlaceholder(_ title: String) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            RoundedRectangle(cornerRadius: DS.Radius.md)
                .fill(DS.Colors.cardElevated)
                .frame(height: 200)
                .overlay(
                    Image(systemName: "video.fill")
                        .font(.system(size: 32))
                        .foregroundColor(DS.Colors.textSecondary.opacity(0.3))
                )

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(DS.Colors.textSecondary)
        }
    }

    // MARK: - Lock Overlay
    private var lockOverlay: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()

            VStack(spacing: DS.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.primaryPurple.opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(DS.Colors.primaryGradient)
                }

                Text("This feature requires Premium")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)

                Text("Compare your videos with viral content to see what works")
                    .font(.system(size: 14))
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)

                GradientButton("Upgrade Now", icon: "crown.fill") {
                    showPaywall = true
                }
                .padding(.horizontal, DS.Spacing.xxl)
            }
            .padding(DS.Spacing.lg)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(DS.Radius.lg)
    }
}

// MARK: - Placeholder TextField Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
