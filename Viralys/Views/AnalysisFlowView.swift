import SwiftUI

// MARK: - Media Input
/// Represents the user's selected media for analysis
enum MediaInput: Identifiable {
    case video(URL)
    case images([UIImage])

    var id: String {
        switch self {
        case .video(let url): return url.absoluteString
        case .images(let imgs): return "images-\(imgs.count)-\(UUID().uuidString)"
        }
    }
}

// MARK: - Analysis Flow View
/// Container for the full analysis flow: preview/slideshow → analyzing → results
struct AnalysisFlowView: View {
    let input: MediaInput
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var flowStep: FlowStep = .initial
    @State private var analysisResult: AnalysisResult?
    @State private var videoURL: URL?
    @State private var slideshowConfig: SlideshowConfig?

    enum FlowStep: Equatable {
        case initial
        case slideshowBuilder
        case preview
        case analyzing
        case results
    }

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            switch flowStep {
            case .initial:
                Color.clear.onAppear { resolveInitialStep() }

            case .slideshowBuilder:
                if case .images(let images) = input {
                    SlideshowBuilderView(images: images) { url, config in
                        videoURL = url
                        slideshowConfig = config
                        withAnimation(DS.Anim.spring) {
                            flowStep = .preview
                        }
                    }
                    .transition(.opacity)
                }

            case .preview:
                if let url = videoURL {
                    VideoPreviewView(
                        videoURL: url,
                        onAnalyze: {
                            appState.recordUpload()
                            withAnimation(DS.Anim.spring) {
                                flowStep = .analyzing
                            }
                        },
                        onCancel: { dismiss() }
                    )
                    .transition(.opacity)
                }

            case .analyzing:
                if let url = videoURL {
                    AnalyzingView(videoURL: url, slideshowConfig: slideshowConfig) { result in
                        analysisResult = result
                        if let result = result {
                            appState.addResult(result)
                        }
                        withAnimation(DS.Anim.spring) {
                            flowStep = .results
                        }
                    }
                    .transition(.opacity)
                }

            case .results:
                if let result = analysisResult {
                    ResultsView(result: result, onDismiss: { dismiss() })
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    errorView
                }
            }
        }
        .animation(DS.Anim.spring, value: flowStep)
    }

    // MARK: - Resolve Initial Step
    private func resolveInitialStep() {
        switch input {
        case .video(let url):
            videoURL = url
            flowStep = .preview
        case .images:
            flowStep = .slideshowBuilder
        }
    }

    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.error)

            Text("Something went wrong")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)

            Text("Please try again with a different video.")
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)

            GradientButton("Try Again") {
                dismiss()
            }
            .padding(.horizontal, DS.Spacing.xxl)
        }
        .padding(DS.Spacing.lg)
    }
}
