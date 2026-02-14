import SwiftUI
import AVFoundation

// MARK: - Camera Recorder
/// Wraps UIImagePickerController for recording video directly from the camera
struct CameraRecorder: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) var dismiss

    /// Check if camera is available on this device
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
            && (UIImagePickerController.availableMediaTypes(for: .camera)?.contains("public.movie") ?? false)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.videoMaximumDuration = 120 // 2 minutes max
        picker.cameraCaptureMode = .video
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraRecorder

        init(_ parent: CameraRecorder) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard let mediaURL = info[.mediaURL] as? URL else {
                parent.dismiss()
                return
            }

            // Copy to a stable temp location
            let tempDir = FileManager.default.temporaryDirectory
            let destURL = tempDir.appendingPathComponent(UUID().uuidString + ".mov")

            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: mediaURL, to: destURL)

                DispatchQueue.main.async {
                    self.parent.videoURL = destURL
                    self.parent.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    self.parent.dismiss()
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
