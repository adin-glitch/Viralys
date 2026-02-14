import SwiftUI

// MARK: - Text Results View
/// Displays text analysis results with score ring, optimized text, sub-scores, and suggestions
struct TextResultsView: View {
    let result: TextAnalysisResult
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Spacing.lg) {
                    // Close button
                    HStack {
                        Spacer()
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(DS.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.md)

                    // Platform badge
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: result.platform.icon)
                        Text(result.platformLabel)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.accent)
                    .padding(.horizontal, DS.Spacing.md)
                    .padding(.vertical, DS.Spacing.xs + 2)
                    .background(DS.Colors.accent.opacity(0.15))
                    .cornerRadius(DS.Radius.xl)

                    // Score Ring
                    ScoreRing(score: result.score)
                        .padding(.top, DS.Spacing.sm)

                    // Score subtext
                    Text(DS.Colors.scoreSubtext(for: result.score))
                        .font(.system(size: 15))
                        .foregroundColor(DS.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DS.Spacing.xl)

                    // Optimized text card
                    OptimizedTextCard(optimizedText: result.optimizedText)
                        .padding(.horizontal, DS.Spacing.lg)

                    // Original vs optimized comparison
                    comparisonSection
                        .padding(.horizontal, DS.Spacing.lg)

                    // Sub-score breakdown
                    VStack(alignment: .leading, spacing: DS.Spacing.md) {
                        Text("Score Breakdown")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DS.Colors.textPrimary)
                            .padding(.horizontal, DS.Spacing.lg)

                        VStack(spacing: DS.Spacing.sm) {
                            AnalysisCard(
                                icon: "bolt.fill",
                                title: "Hook Strength",
                                score: result.hookScore,
                                description: result.hookDescription,
                                index: 0
                            )
                            AnalysisCard(
                                icon: "hand.thumbsup.fill",
                                title: "Engagement",
                                score: result.engagementScore,
                                description: result.engagementDescription,
                                index: 1
                            )
                            AnalysisCard(
                                icon: "text.alignleft",
                                title: "Clarity",
                                score: result.clarityScore,
                                description: result.clarityDescription,
                                index: 2
                            )
                            AnalysisCard(
                                icon: result.platform == .twitter ? "bird" : "briefcase.fill",
                                title: "Format",
                                score: result.formatScore,
                                description: result.formatDescription,
                                index: 3
                            )
                        }
                        .padding(.horizontal, DS.Spacing.lg)
                    }

                    // Suggestions
                    if !result.suggestions.isEmpty {
                        VStack(alignment: .leading, spacing: DS.Spacing.md) {
                            Text("Suggestions")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(DS.Colors.textPrimary)
                                .padding(.horizontal, DS.Spacing.lg)

                            VStack(spacing: DS.Spacing.sm) {
                                ForEach(Array(result.suggestions.enumerated()), id: \.element.id) { index, suggestion in
                                    TextSuggestionCard(suggestion: suggestion, index: index)
                                }
                            }
                            .padding(.horizontal, DS.Spacing.lg)
                        }
                    }

                    // Done button
                    GradientButton("Done", icon: "checkmark") {
                        onDismiss()
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.xxl)
                }
            }

            // Confetti for high scores
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            withAnimation(DS.Anim.spring) {
                appeared = true
            }
            if result.score > 85 {
                showConfetti = true
            }
        }
    }

    // MARK: - Comparison Section

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Original Post")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DS.Colors.textSecondary)

            Text(result.originalText)
                .font(.system(size: 14))
                .foregroundColor(DS.Colors.textSecondary.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                .padding(DS.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DS.Colors.card)
                .cornerRadius(DS.Radius.md)
        }
    }
}
