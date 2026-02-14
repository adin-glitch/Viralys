import SwiftUI
import AVKit

// MARK: - Video Preview View
/// Shows video preview with metadata before analysis
struct VideoPreviewView: View {
    let videoURL: URL
    let onAnalyze: () -> Void
    let onCancel: () -> Void

    @State private var player: AVPlayer?
    @State private var duration: String = "--"
    @State private var resolution: String = "--"
    @State private var fileSize: String = "--"
    @State private var appeared = false
    @State private var showSizeAlert = false

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            // Video player
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea(edges: .top)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }

            // Gradient overlay at bottom
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
            }
            .ignoresSafeArea()

            // Bottom sheet content
            VStack {
                Spacer()

                VStack(spacing: DS.Spacing.lg) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 36, height: 5)

                    // Video metadata
                    HStack(spacing: DS.Spacing.xl) {
                        metadataItem(icon: "clock", label: "Duration", value: duration)
                        metadataItem(icon: "arrow.up.left.and.arrow.down.right", label: "Resolution", value: resolution)
                        metadataItem(icon: "doc", label: "Size", value: fileSize)
                    }

                    // Analyze button
                    GradientButton("Analyze Video", icon: "sparkles") {
                        onAnalyze()
                    }

                    // Choose different
                    TextButton("Choose Different Video", color: DS.Colors.textSecondary) {
                        onCancel()
                    }
                }
                .padding(DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.xl)
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 50)

            // Close button
            VStack {
                HStack {
                    Button(action: {
                        HapticManager.selection()
                        onCancel()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, DS.Spacing.md)
                    .padding(.top, DS.Spacing.xxl)

                    Spacer()
                }
                Spacer()
            }
        }
        .alert("Video Too Large", isPresented: $showSizeAlert) {
            Button("Choose Another", role: .cancel) { onCancel() }
            Button("Analyze Anyway") { onAnalyze() }
        } message: {
            Text("This video is over 500MB. Consider compressing it for better results.")
        }
        .onAppear {
            setupPlayer()
            loadMetadata()
            withAnimation(DS.Anim.spring.delay(0.3)) {
                appeared = true
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    // MARK: - Metadata Item
    private func metadataItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(DS.Colors.accent)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(DS.Colors.textPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(DS.Colors.textSecondary)
        }
    }

    // MARK: - Setup
    private func setupPlayer() {
        let avPlayer = AVPlayer(url: videoURL)
        avPlayer.isMuted = true
        avPlayer.play()

        // Loop playback
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { _ in
            avPlayer.seek(to: .zero)
            avPlayer.play()
        }

        player = avPlayer
    }

    private func loadMetadata() {
        let asset = AVAsset(url: videoURL)

        // Duration
        let dur = CMTimeGetSeconds(asset.duration)
        duration = dur.durationDisplay

        // Resolution
        if let track = asset.tracks(withMediaType: .video).first {
            let size = track.naturalSize
            resolution = "\(Int(size.width))x\(Int(size.height))"
        }

        // File size
        if let attrs = try? FileManager.default.attributesOfItem(atPath: videoURL.path),
           let size = attrs[.size] as? Int64 {
            fileSize = size.fileSizeDisplay

            // Check if too large
            if size > 500_000_000 {
                showSizeAlert = true
            }
        }
    }
}
