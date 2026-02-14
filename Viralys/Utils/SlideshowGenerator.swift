import AVFoundation
import CoreGraphics
import UIKit

// MARK: - Slideshow Generator
/// Creates an MP4 video from an array of images with configurable transitions
final class SlideshowGenerator {

    static func generate(
        images: [UIImage],
        config: SlideshowConfig,
        progress: @escaping (Double) -> Void,
        completion: @escaping (URL?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("slideshow_\(UUID().uuidString).mp4")

            try? FileManager.default.removeItem(at: outputURL)

            let width = 1080
            let height = 1920
            let fps: Int32 = 30

            guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height
            ]

            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: input,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                    kCVPixelBufferWidthKey as String: width,
                    kCVPixelBufferHeightKey as String: height
                ]
            )

            writer.add(input)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)

            let transitionDuration = config.transitionType == .none ? 0.0 : 0.5
            let transitionFrameCount = Int(transitionDuration * Double(fps))
            let slideFrameCount = Int(config.durationPerSlide * Double(fps))
            let targetSize = CGSize(width: width, height: height)

            var frameIndex: Int64 = 0

            for (imgIdx, image) in images.enumerated() {
                let resized = resizeToFill(image, size: targetSize)

                // Main slide frames (minus transition at end if not last)
                let mainFrames = imgIdx < images.count - 1
                    ? slideFrameCount - transitionFrameCount
                    : slideFrameCount

                for _ in 0..<mainFrames {
                    autoreleasepool {
                        while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.005) }
                        if let buffer = pixelBuffer(from: resized, width: width, height: height) {
                            adaptor.append(buffer, withPresentationTime: CMTime(value: frameIndex, timescale: fps))
                            frameIndex += 1
                        }
                    }
                }

                // Transition frames to next image
                if imgIdx < images.count - 1 && transitionFrameCount > 0 {
                    let nextResized = resizeToFill(images[imgIdx + 1], size: targetSize)

                    for t in 0..<transitionFrameCount {
                        autoreleasepool {
                            while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.005) }
                            let pct = Double(t) / Double(transitionFrameCount)
                            if let buffer = transitionBuffer(
                                from: resized, to: nextResized, progress: pct,
                                type: config.transitionType, width: width, height: height
                            ) {
                                adaptor.append(buffer, withPresentationTime: CMTime(value: frameIndex, timescale: fps))
                                frameIndex += 1
                            }
                        }
                    }
                }

                DispatchQueue.main.async {
                    progress(Double(imgIdx + 1) / Double(images.count))
                }
            }

            input.markAsFinished()
            let sem = DispatchSemaphore(value: 0)
            writer.finishWriting { sem.signal() }
            sem.wait()

            DispatchQueue.main.async {
                completion(writer.status == .completed ? outputURL : nil)
            }
        }
    }

    // MARK: - Image Resizing (fill to 9:16)

    private static func resizeToFill(_ image: UIImage, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.fill(CGRect(origin: .zero, size: size))

            let imgSize = image.size
            let scaleW = size.width / imgSize.width
            let scaleH = size.height / imgSize.height
            let scale = max(scaleW, scaleH) // Fill (crop edges)
            let drawW = imgSize.width * scale
            let drawH = imgSize.height * scale
            let drawX = (size.width - drawW) / 2
            let drawY = (size.height - drawH) / 2

            image.draw(in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))
        }
    }

    // MARK: - Pixel Buffer Creation

    private static func pixelBuffer(from image: UIImage, width: Int, height: Int) -> CVPixelBuffer? {
        var buffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32ARGB, attrs as CFDictionary, &buffer)
        guard let pb = buffer else { return nil }

        CVPixelBufferLockBaseAddress(pb, [])
        guard let ctx = CGContext(
            data: CVPixelBufferGetBaseAddress(pb),
            width: width, height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pb),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(pb, [])
            return nil
        }

        ctx.translateBy(x: 0, y: CGFloat(height))
        ctx.scaleBy(x: 1, y: -1)
        UIGraphicsPushContext(ctx)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pb, [])
        return pb
    }

    // MARK: - Transition Rendering

    private static func transitionBuffer(
        from: UIImage, to: UIImage, progress: Double,
        type: SlideshowConfig.TransitionType, width: Int, height: Int
    ) -> CVPixelBuffer? {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)

        let blended = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)

            switch type {
            case .fade:
                from.draw(in: rect, blendMode: .normal, alpha: 1.0 - progress)
                to.draw(in: rect, blendMode: .normal, alpha: progress)

            case .slide:
                let offset = size.width * progress
                from.draw(in: rect.offsetBy(dx: -offset, dy: 0))
                to.draw(in: rect.offsetBy(dx: size.width - offset, dy: 0))

            case .zoom:
                let scale = 1.0 + progress * 0.3
                let zoomRect = CGRect(
                    x: rect.midX - rect.width * scale / 2,
                    y: rect.midY - rect.height * scale / 2,
                    width: rect.width * scale,
                    height: rect.height * scale
                )
                from.draw(in: zoomRect, blendMode: .normal, alpha: 1.0 - progress)
                to.draw(in: rect, blendMode: .normal, alpha: progress)

            case .none:
                to.draw(in: rect)
            }
        }

        return pixelBuffer(from: blended, width: width, height: height)
    }
}
