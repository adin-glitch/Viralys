import SwiftUI

// MARK: - Home View
/// Main screen with upload card, recent analyses, and premium banner
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showMediaPicker = false
    @State private var showCamera = false
    @State private var mediaSelection: MediaSelection?
    @State private var selectedVideoURL: URL?
    @State private var activeMedia: MediaInput?
    @State private var showPaywall = false
    @State private var showLimitAlert = false
    @State private var showNoCameraAlert = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                DS.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerView

                        VStack(spacing: DS.Spacing.lg) {
                            uploadCard

                            if !appState.isPremium {
                                FreeTierCard(
                                    remaining: appState.remainingUploads,
                                    onUpgrade: { showPaywall = true }
                                )
                                .padding(.horizontal, DS.Spacing.lg)
                            }

                            recentAnalysesSection

                            if !appState.isPremium && !appState.dismissedPremiumBanner {
                                Spacer().frame(height: 100)
                            }
                        }
                        .padding(.top, DS.Spacing.lg)
                    }
                }

                if !appState.isPremium && !appState.dismissedPremiumBanner {
                    PremiumBanner(
                        onUpgrade: { showPaywall = true },
                        onDismiss: {
                            withAnimation(DS.Anim.spring) {
                                appState.dismissedPremiumBanner = true
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        // Media picker (videos + images)
        .sheet(isPresented: $showMediaPicker, onDismiss: {
            handleMediaSelection()
        }) {
            MediaPicker(selection: $mediaSelection)
        }
        // Camera recorder — on dismiss, launch analysis flow
        .fullScreenCover(isPresented: $showCamera, onDismiss: {
            presentVideoIfNeeded()
        }) {
            CameraRecorder(videoURL: $selectedVideoURL)
                .ignoresSafeArea()
        }
        // Analysis flow — uses item: binding so input is guaranteed non-nil
        .fullScreenCover(item: $activeMedia) { media in
            AnalysisFlowView(input: media)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
        .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
            Button("Upgrade Now") { showPaywall = true }
            Button("Maybe Later", role: .cancel) {}
        } message: {
            Text("You've used all 3 free uploads today. Upgrade to Premium for unlimited access.")
        }
        .alert("Camera Not Available", isPresented: $showNoCameraAlert) {
            Button("Choose from Library") { showMediaPicker = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Camera is not available on this device. You can choose a video from your photo library instead.")
        }
    }

    // MARK: - Handle Media Selection
    private func handleMediaSelection() {
        guard let selection = mediaSelection else { return }
        mediaSelection = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            switch selection {
            case .video(let url):
                activeMedia = .video(url)
            case .images(let images):
                activeMedia = .images(images)
            }
        }
    }

    // MARK: - Present Video from Camera
    private func presentVideoIfNeeded() {
        guard let url = selectedVideoURL else { return }
        selectedVideoURL = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            activeMedia = .video(url)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        ZStack(alignment: .bottom) {
            DS.Colors.primaryGradient
                .frame(height: DS.Layout.headerHeight)

            LinearGradient(
                colors: [.clear, DS.Colors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)

            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: "waveform.and.magnifyingglass")
                    .font(.system(size: 28))
                    .foregroundColor(.white)

                Text("Viralys")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Upload Card
    private var uploadCard: some View {
        VStack(spacing: DS.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DS.Colors.primaryGradient.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: "video.badge.plus")
                    .font(.system(size: 28))
                    .foregroundStyle(DS.Colors.primaryGradient)
            }

            Text("Analyze Your Content")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)

            Text("Record, upload a video, or select photos")
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textSecondary)

            HStack(spacing: DS.Spacing.md) {
                GradientButton("Record", icon: "camera.fill") {
                    handleUpload(source: .camera)
                }

                GradientButton("Library", icon: "photo.on.rectangle", style: .secondary) {
                    handleUpload(source: .library)
                }
            }
        }
        .padding(DS.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(DS.Colors.card)
        .cornerRadius(DS.Radius.lg)
        .gradientBorder()
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - Recent Analyses
    private var recentAnalysesSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Recent Analysis")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.lg)

            if appState.analysisHistory.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.md) {
                        ForEach(appState.analysisHistory.prefix(5)) { result in
                            NavigationLink(destination: ResultsView(result: result, onDismiss: nil)) {
                                RecentAnalysisCard(result: result)
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "film.stack")
                .font(.system(size: 40))
                .foregroundColor(DS.Colors.textSecondary.opacity(0.5))

            Text("No analyses yet")
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textSecondary)

            TextButton("Upload your first video") {
                handleUpload(source: .library)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.xl)
    }

    // MARK: - Actions
    enum VideoSource { case camera, library }

    private func handleUpload(source: VideoSource) {
        guard appState.canUpload else {
            HapticManager.warning()
            showLimitAlert = true
            return
        }

        switch source {
        case .camera:
            if CameraRecorder.isAvailable {
                showCamera = true
            } else {
                showNoCameraAlert = true
            }
        case .library:
            showMediaPicker = true
        }
    }
}
