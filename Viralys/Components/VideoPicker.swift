import SwiftUI
import PhotosUI

// MARK: - Media Selection Result
enum MediaSelection: Identifiable {
    case video(URL)
    case images([UIImage])

    var id: String {
        switch self {
        case .video(let url): return url.absoluteString
        case .images(let imgs): return "images-\(imgs.count)-\(UUID().uuidString)"
        }
    }
}

// MARK: - Media Picker
/// Unified picker supporting both videos and multi-image selection for slideshows
struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selection: MediaSelection?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .any(of: [.videos, .images])
        config.selectionLimit = 10
        config.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker

        init(_ parent: MediaPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard !results.isEmpty else {
                parent.dismiss()
                return
            }

            // Check if first result is a video
            let firstProvider = results[0].itemProvider
            if firstProvider.hasItemConformingToTypeIdentifier("public.movie") {
                loadVideo(from: firstProvider)
            } else {
                loadImages(from: results)
            }
        }

        private func loadVideo(from provider: NSItemProvider) {
            provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { [weak self] url, error in
                guard let url = url, error == nil else {
                    DispatchQueue.main.async { self?.parent.dismiss() }
                    return
                }

                let dest = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + "." + url.pathExtension)
                do {
                    try? FileManager.default.removeItem(at: dest)
                    try FileManager.default.copyItem(at: url, to: dest)
                    DispatchQueue.main.async {
                        self?.parent.selection = .video(dest)
                        self?.parent.dismiss()
                    }
                } catch {
                    DispatchQueue.main.async { self?.parent.dismiss() }
                }
            }
        }

        private func loadImages(from results: [PHPickerResult]) {
            var images: [UIImage] = Array(repeating: UIImage(), count: results.count)
            let group = DispatchGroup()
            var loadedCount = 0

            for (index, result) in results.enumerated() {
                guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        images[index] = image
                        loadedCount += 1
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) { [weak self] in
                let valid = images.filter { $0.size.width > 0 }
                if valid.isEmpty {
                    self?.parent.dismiss()
                } else {
                    self?.parent.selection = .images(valid)
                    self?.parent.dismiss()
                }
            }
        }
    }
}
