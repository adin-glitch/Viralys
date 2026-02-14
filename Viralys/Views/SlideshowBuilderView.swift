import SwiftUI

// MARK: - Slideshow Builder View
/// Lets users configure and generate a slideshow from selected images
struct SlideshowBuilderView: View {
    @State var images: [UIImage]
    let onGenerated: (URL, SlideshowConfig) -> Void

    @State private var durationPerSlide: Double = 2.0
    @State private var transitionType: SlideshowConfig.TransitionType = .fade
    @State private var isGenerating = false
    @State private var generationProgress: Double = 0
    @State private var showError = false

    private var totalDuration: Double { Double(images.count) * durationPerSlide }

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            if isGenerating {
                generatingOverlay
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.lg) {
                        // Title
                        Text("Create Slideshow")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(DS.Colors.textPrimary)
                            .padding(.top, DS.Spacing.xl)

                        Text("\(images.count) photos selected")
                            .font(.system(size: 15))
                            .foregroundColor(DS.Colors.textSecondary)

                        // Image strip
                        imageStrip

                        // Settings
                        settingsSection

                        // Total duration
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(DS.Colors.accent)
                            Text("Total: \(totalDuration.durationDisplay)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DS.Colors.textPrimary)
                        }
                        .padding(DS.Spacing.md)
                        .frame(maxWidth: .infinity)
                        .background(DS.Colors.accent.opacity(0.08))
                        .cornerRadius(DS.Radius.md)
                        .padding(.horizontal, DS.Spacing.lg)

                        // Generate button
                        GradientButton("Generate Slideshow", icon: "wand.and.stars") {
                            generateSlideshow()
                        }
                        .padding(.horizontal, DS.Spacing.lg)

                        Spacer().frame(height: DS.Spacing.xxl)
                    }
                }
            }
        }
        .alert("Generation Failed", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text("Could not create the slideshow. Please try again.")
        }
    }

    // MARK: - Image Strip
    private var imageStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.md) {
                ForEach(images.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        // Thumbnail
                        Image(uiImage: images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))

                        // Order number
                        Text("\(index + 1)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(DS.Colors.primaryPurple)
                            .clipShape(Circle())
                            .offset(x: -4, y: 4)

                        // Remove button
                        if images.count > 2 {
                            Button(action: {
                                HapticManager.selection()
                                withAnimation(DS.Anim.quick) {
                                    _ = images.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                                    .background(DS.Colors.error)
                                    .clipShape(Circle())
                            }
                            .offset(x: 4, y: -4)
                        }
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }

    // MARK: - Settings
    private var settingsSection: some View {
        VStack(spacing: DS.Spacing.md) {
            // Duration slider
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack {
                    Text("Duration per Slide")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DS.Colors.textPrimary)
                    Spacer()
                    Text(String(format: "%.1fs", durationPerSlide))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(DS.Colors.accent)
                }

                Slider(value: $durationPerSlide, in: 1.0...5.0, step: 0.5)
                    .accentColor(DS.Colors.accent)

                HStack {
                    Text("1s").font(.system(size: 11)).foregroundColor(DS.Colors.textSecondary)
                    Spacer()
                    Text("5s").font(.system(size: 11)).foregroundColor(DS.Colors.textSecondary)
                }
            }

            Divider().background(DS.Colors.cardElevated)

            // Transition picker
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text("Transition")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DS.Colors.textPrimary)

                HStack(spacing: DS.Spacing.sm) {
                    ForEach(SlideshowConfig.TransitionType.allCases, id: \.rawValue) { type in
                        transitionButton(type)
                    }
                }
            }
        }
        .padding(DS.Spacing.lg)
        .cardStyle()
        .padding(.horizontal, DS.Spacing.lg)
    }

    private func transitionButton(_ type: SlideshowConfig.TransitionType) -> some View {
        let isSelected = transitionType == type
        return Button(action: {
            HapticManager.selection()
            transitionType = type
        }) {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: type.icon)
                    .font(.system(size: 18))
                Text(type.rawValue)
                    .font(.system(size: 11))
            }
            .foregroundColor(isSelected ? DS.Colors.accent : DS.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.sm)
            .background(isSelected ? DS.Colors.accent.opacity(0.12) : DS.Colors.cardElevated)
            .cornerRadius(DS.Radius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .stroke(isSelected ? DS.Colors.accent : Color.clear, lineWidth: 1)
            )
        }
    }

    // MARK: - Generating Overlay
    private var generatingOverlay: some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            ProgressView(value: generationProgress)
                .progressViewStyle(CircularProgressViewStyle(tint: DS.Colors.accent))
                .scaleEffect(2)

            Text("Creating slideshow...")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)

            Text("\(Int(generationProgress * 100))%")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(DS.Colors.accent)

            Spacer()
        }
    }

    // MARK: - Generate
    private func generateSlideshow() {
        HapticManager.impact()
        isGenerating = true

        let config = SlideshowConfig(
            durationPerSlide: durationPerSlide,
            transitionType: transitionType,
            imageCount: images.count
        )

        SlideshowGenerator.generate(images: images, config: config, progress: { p in
            withAnimation { generationProgress = p }
        }) { url in
            isGenerating = false
            if let url = url {
                HapticManager.success()
                onGenerated(url, config)
            } else {
                HapticManager.error()
                showError = true
            }
        }
    }
}
