import SwiftUI

// MARK: - Text Optimizer View
/// Main tab view for text post optimization: platform picker, text input, optimize button, recent analyses
struct TextOptimizerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPlatform: SocialPlatform = .twitter
    @State private var inputText = ""
    @State private var isAnalyzing = false
    @State private var analysisResult: TextAnalysisResult?
    @State private var showResults = false
    @State private var showUpgradeAlert = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var analysisTask: Task<Void, Never>?
    @State private var appeared = false

    private var charCount: Int { inputText.count }
    private var charLimit: Int { selectedPlatform.charLimit }
    private var isOverLimit: Bool { charCount > charLimit }
    private var canOptimize: Bool { !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOverLimit }

    var body: some View {
        NavigationView {
            ZStack {
                DS.Colors.background.ignoresSafeArea()

                if isAnalyzing {
                    TextAnalyzingView(platform: selectedPlatform) {
                        analysisTask?.cancel()
                        analysisTask = nil
                        isAnalyzing = false
                    }
                } else {
                    mainContent
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showResults) {
            if let result = analysisResult {
                TextResultsView(result: result) {
                    showResults = false
                }
            }
        }
        .alert("Upgrade to Premium", isPresented: $showUpgradeAlert) {
            Button("Maybe Later", role: .cancel) {}
        } message: {
            Text("You've used all 3 free text optimizations today. Upgrade to Premium for unlimited optimizations.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
        .onAppear {
            withAnimation(DS.Anim.spring) {
                appeared = true
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DS.Spacing.lg) {
                // Header
                headerSection

                // Platform picker
                PlatformPicker(selected: $selectedPlatform)
                    .padding(.horizontal, DS.Spacing.lg)

                // Text input
                textInputSection
                    .padding(.horizontal, DS.Spacing.lg)

                // Optimize button
                optimizeButton
                    .padding(.horizontal, DS.Spacing.lg)

                // Free tier info
                if !appState.isPremium {
                    freeTierInfo
                        .padding(.horizontal, DS.Spacing.lg)
                }

                // Recent analyses
                if !appState.textAnalysisHistory.isEmpty {
                    recentAnalysesSection
                }

                Spacer(minLength: DS.Spacing.xxl)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            Text("Optimize Post")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)

            Text("Paste your post and let AI boost its virality")
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textSecondary)
        }
        .padding(.top, DS.Spacing.xxl)
    }

    // MARK: - Text Input

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            ZStack(alignment: .topLeading) {
                // Placeholder
                if inputText.isEmpty {
                    Text("Paste your \(selectedPlatform.shortName) post here...")
                        .font(.system(size: 15))
                        .foregroundColor(DS.Colors.textSecondary.opacity(0.5))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }

                TextEditor(text: $inputText)
                    .font(.system(size: 15))
                    .foregroundColor(DS.Colors.textPrimary)
                    .frame(minHeight: 120, maxHeight: 200)
                    .onAppear {
                        UITextView.appearance().backgroundColor = .clear
                    }
            }
            .padding(DS.Spacing.md)
            .background(DS.Colors.cardElevated)
            .cornerRadius(DS.Radius.lg)

            // Character count
            HStack {
                Spacer()
                Text("\(charCount)/\(charLimit)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(isOverLimit ? DS.Colors.error : DS.Colors.textSecondary)
            }
        }
    }

    // MARK: - Optimize Button

    private var optimizeButton: some View {
        GradientButton("Optimize for Virality", icon: "sparkles") {
            guard canOptimize else { return }

            if !appState.canOptimizeText {
                showUpgradeAlert = true
                return
            }

            startAnalysis()
        }
        .opacity(canOptimize ? 1.0 : 0.5)
    }

    // MARK: - Free Tier Info

    private var freeTierInfo: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "sparkle")
                .font(.system(size: 13))
                .foregroundColor(DS.Colors.accent)

            Text("\(appState.remainingTextOptimizations) free optimizations remaining today")
                .font(.system(size: 13))
                .foregroundColor(DS.Colors.textSecondary)
        }
    }

    // MARK: - Recent Analyses

    private var recentAnalysesSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Recent Optimizations")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.md) {
                    ForEach(appState.textAnalysisHistory.prefix(10)) { result in
                        recentTextCard(result)
                            .onTapGesture {
                                analysisResult = result
                                showResults = true
                            }
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
            }
        }
    }

    private func recentTextCard(_ result: TextAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            // Platform icon + score
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .fill(DS.Colors.cardElevated)
                    .frame(width: DS.Layout.thumbnailSize, height: DS.Layout.thumbnailSize)
                    .overlay(
                        Image(systemName: result.platform.icon)
                            .font(.system(size: 24))
                            .foregroundColor(DS.Colors.textSecondary)
                    )

                ScoreBadge(score: result.score, size: 28)
                    .offset(x: 4, y: -4)
            }

            Text(result.date.shortDisplay)
                .font(.system(size: 11))
                .foregroundColor(DS.Colors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: DS.Layout.thumbnailSize)
    }

    // MARK: - Analysis Logic

    private func startAnalysis() {
        isAnalyzing = true
        let text = inputText
        let platform = selectedPlatform

        analysisTask = Task {
            do {
                let result = try await TextPostAnalyzer.analyze(text: text, platform: platform)

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    appState.recordTextOptimization()
                    appState.addTextResult(result)
                    analysisResult = result
                    isAnalyzing = false
                    showResults = true
                    HapticManager.success()
                }
            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    isAnalyzing = false
                    errorMessage = error.localizedDescription
                    showError = true
                    HapticManager.error()
                }
            }
        }
    }
}
