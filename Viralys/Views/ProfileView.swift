import SwiftUI

// MARK: - Profile View
/// User profile with stats, history, and settings
struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPaywall = false
    @State private var selectedResult: AnalysisResult?
    @State private var showResultDetail = false
    @State private var selectedTextResult: TextAnalysisResult?
    @State private var showTextResultDetail = false
    @State private var appeared = false
    @State private var showAPIKeySheet = false
    @State private var apiKeyInput = ""
    @State private var showAPIKeySaved = false

    var body: some View {
        NavigationView {
            ZStack {
                DS.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.lg) {
                        // Header
                        headerSection

                        // Stats
                        statsSection

                        // Subscription status
                        subscriptionCard

                        // Video History
                        historySection

                        // Text Optimization History
                        textHistorySection

                        // Settings
                        settingsSection

                        // App version
                        Text("Viralys v1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(DS.Colors.textSecondary.opacity(0.5))
                            .padding(.top, DS.Spacing.md)
                            .padding(.bottom, DS.Spacing.xxl)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showResultDetail) {
            if let result = selectedResult {
                NavigationView {
                    ResultsView(result: result, onDismiss: { showResultDetail = false })
                        .environmentObject(appState)
                        .navigationBarHidden(true)
                }
            }
        }
        .sheet(isPresented: $showTextResultDetail) {
            if let result = selectedTextResult {
                TextResultsView(result: result, onDismiss: { showTextResultDetail = false })
            }
        }
        .sheet(isPresented: $showAPIKeySheet) {
            apiKeySheet
        }
        .onAppear {
            withAnimation(DS.Anim.spring) {
                appeared = true
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: DS.Spacing.md) {
            // Avatar placeholder
            ZStack {
                Circle()
                    .fill(DS.Colors.primaryGradient)
                    .frame(width: 80, height: 80)

                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }

            Text("Profile")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)
        }
        .padding(.top, DS.Spacing.xxl)
    }

    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: DS.Spacing.md) {
            statItem(
                icon: "arrow.up.circle.fill",
                value: "\(appState.totalUploads)",
                label: "Uploads"
            )
            statItem(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(appState.averageScore)",
                label: "Avg Score"
            )
            statItem(
                icon: "trophy.fill",
                value: "\(appState.bestScore)",
                label: "Best"
            )
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
        .padding(.horizontal, DS.Spacing.lg)
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(DS.Colors.primaryGradient)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(DS.Colors.textPrimary)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(DS.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Subscription Card
    private var subscriptionCard: some View {
        VStack(spacing: DS.Spacing.md) {
            if appState.isPremium {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(DS.Colors.warning)
                    Text("Premium")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.Colors.warning)
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(DS.Colors.warning.opacity(0.15))
                .cornerRadius(DS.Radius.xl)

                Text("Unlimited uploads")
                    .font(.system(size: 14))
                    .foregroundColor(DS.Colors.textSecondary)

                GradientButton("Manage Subscription", style: .secondary) {
                    // Placeholder
                }
            } else {
                HStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "star.fill")
                        .foregroundColor(DS.Colors.accent)
                    Text("Free Plan")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.Colors.accent)
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
                .background(DS.Colors.accent.opacity(0.15))
                .cornerRadius(DS.Radius.xl)

                Text("3 uploads per day")
                    .font(.system(size: 14))
                    .foregroundColor(DS.Colors.textSecondary)

                GradientButton("Upgrade to Premium", icon: "crown.fill") {
                    showPaywall = true
                }
            }
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - History
    private var historySection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Upload History")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.lg)

            if appState.analysisHistory.isEmpty {
                VStack(spacing: DS.Spacing.md) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 32))
                        .foregroundColor(DS.Colors.textSecondary.opacity(0.4))
                    Text("No history yet")
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.xl)
            } else {
                LazyVStack(spacing: DS.Spacing.sm) {
                    ForEach(appState.analysisHistory) { result in
                        historyRow(result)
                            .onTapGesture {
                                selectedResult = result
                                showResultDetail = true
                            }
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
            }
        }
    }

    private func historyRow(_ result: AnalysisResult) -> some View {
        HStack(spacing: DS.Spacing.md) {
            // Thumbnail
            if let data = result.thumbnailData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            } else {
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .fill(DS.Colors.cardElevated)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "video.fill")
                            .foregroundColor(DS.Colors.textSecondary)
                            .font(.system(size: 16))
                    )
            }

            // Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(result.date.shortDisplay)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DS.Colors.textPrimary)

                Text("\(result.durationDisplay) \u{2022} \(result.resolution)")
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            // Score
            ScoreBadge(score: result.score)

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(DS.Colors.textSecondary)
        }
        .padding(DS.Spacing.md)
        .cardStyle()
        .contextMenu {
            Button(role: .destructive) {
                withAnimation(DS.Anim.spring) {
                    appState.deleteResult(id: result.id)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Text History
    private var textHistorySection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Text Optimization History")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.lg)

            if appState.textAnalysisHistory.isEmpty {
                VStack(spacing: DS.Spacing.md) {
                    Image(systemName: "text.badge.star")
                        .font(.system(size: 32))
                        .foregroundColor(DS.Colors.textSecondary.opacity(0.4))
                    Text("No text optimizations yet")
                        .font(.system(size: 14))
                        .foregroundColor(DS.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.xl)
            } else {
                // Text stats
                HStack(spacing: DS.Spacing.md) {
                    statItem(
                        icon: "text.badge.star",
                        value: "\(appState.totalTextOptimizations)",
                        label: "Optimized"
                    )
                    statItem(
                        icon: "chart.line.uptrend.xyaxis",
                        value: "\(appState.averageTextScore)",
                        label: "Avg Score"
                    )
                    statItem(
                        icon: "trophy.fill",
                        value: "\(appState.bestTextScore)",
                        label: "Best"
                    )
                }
                .padding(DS.Spacing.lg)
                .cardStyle()
                .padding(.horizontal, DS.Spacing.lg)

                LazyVStack(spacing: DS.Spacing.sm) {
                    ForEach(appState.textAnalysisHistory) { result in
                        textHistoryRow(result)
                            .onTapGesture {
                                selectedTextResult = result
                                showTextResultDetail = true
                            }
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
            }
        }
    }

    private func textHistoryRow(_ result: TextAnalysisResult) -> some View {
        HStack(spacing: DS.Spacing.md) {
            // Platform icon
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .fill(DS.Colors.cardElevated)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: result.platform.icon)
                        .foregroundColor(DS.Colors.textSecondary)
                        .font(.system(size: 20))
                )

            // Info
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(result.date.shortDisplay)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DS.Colors.textPrimary)

                Text(result.previewText)
                    .font(.system(size: 13))
                    .foregroundColor(DS.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            ScoreBadge(score: result.score)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(DS.Colors.textSecondary)
        }
        .padding(DS.Spacing.md)
        .cardStyle()
        .contextMenu {
            Button(role: .destructive) {
                withAnimation(DS.Anim.spring) {
                    appState.deleteTextResult(id: result.id)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - API Key Sheet
    private var apiKeySheet: some View {
        NavigationView {
            ZStack {
                DS.Colors.background.ignoresSafeArea()

                VStack(spacing: DS.Spacing.lg) {
                    // Info
                    VStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(DS.Colors.primaryGradient)

                        Text("Claude API Key")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(DS.Colors.textPrimary)

                        Text("Required for text post optimization. Get your key at console.anthropic.com")
                            .font(.system(size: 14))
                            .foregroundColor(DS.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DS.Spacing.lg)
                    }
                    .padding(.top, DS.Spacing.xl)

                    // Input field
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        SecureField("sk-ant-...", text: $apiKeyInput)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(DS.Colors.textPrimary)
                            .padding(DS.Spacing.md)
                            .background(DS.Colors.cardElevated)
                            .cornerRadius(DS.Radius.lg)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, DS.Spacing.lg)

                    // Save button
                    GradientButton("Save API Key", icon: "checkmark.shield.fill") {
                        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        UserDefaults.standard.set(trimmed, forKey: APIConfig.apiKeyUserDefaultsKey)
                        HapticManager.success()
                        showAPIKeySheet = false
                    }
                    .padding(.horizontal, DS.Spacing.lg)

                    // Remove key button
                    if APIConfig.hasValidKey {
                        TextButton("Remove API Key", color: DS.Colors.error) {
                            UserDefaults.standard.removeObject(forKey: APIConfig.apiKeyUserDefaultsKey)
                            apiKeyInput = ""
                            HapticManager.warning()
                            showAPIKeySheet = false
                        }
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showAPIKeySheet = false
                    }
                    .foregroundColor(DS.Colors.accent)
                }
            }
        }
    }

    // MARK: - Settings
    private var settingsSection: some View {
        VStack(spacing: 0) {
            // API Key row
            Button {
                apiKeyInput = UserDefaults.standard.string(forKey: APIConfig.apiKeyUserDefaultsKey) ?? ""
                showAPIKeySheet = true
            } label: {
                HStack(spacing: DS.Spacing.md) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 16))
                        .foregroundColor(APIConfig.hasValidKey ? DS.Colors.success : DS.Colors.warning)
                        .frame(width: 24)

                    Text("Claude API Key")
                        .font(.system(size: 15))
                        .foregroundColor(DS.Colors.textPrimary)

                    Spacer()

                    Text(APIConfig.hasValidKey ? "Configured" : "Not Set")
                        .font(.system(size: 13))
                        .foregroundColor(APIConfig.hasValidKey ? DS.Colors.success : DS.Colors.textSecondary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DS.Colors.textSecondary.opacity(0.5))
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.md)
            }

            Divider().background(DS.Colors.cardElevated)
            settingsRow(icon: "info.circle", title: "About Viralys")
            Divider().background(DS.Colors.cardElevated)
            settingsRow(icon: "doc.text", title: "Terms of Service")
            Divider().background(DS.Colors.cardElevated)
            settingsRow(icon: "hand.raised", title: "Privacy Policy")
            Divider().background(DS.Colors.cardElevated)
            settingsRow(icon: "envelope", title: "Contact Support")
        }
        .cardStyle()
        .padding(.horizontal, DS.Spacing.lg)
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DS.Colors.textSecondary)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(DS.Colors.textSecondary.opacity(0.5))
        }
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.md)
    }
}
