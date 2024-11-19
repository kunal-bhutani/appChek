//import SwiftUI
//import Vision
//import ImageIO
//
//@MainActor
//class SummaryViewModel: ObservableObject {
//    @Published var beforeImage: UIImage?
//    @Published var afterImage: UIImage?
//    @Published var isProcessing = false
//    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    @Published var errorMessage: String?
//    
//    private let imageTransformViewModel = ImageTransformViewModel()
//    
//    @State private var debounceTimer: Timer?
//    
//    /// Processes the given image.
//    func processImage(_ image: UIImage) {
//        guard let downsizedImage = downsized(image: image) else { return }
//        
//        // Check if the image is already being processed
//        if isProcessing {
//            return // Don't process again until the previous one is done
//        }
//
//        beforeImage = downsizedImage
//        isProcessing = true
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                let resultImage = try self.performProcessing(image: downsizedImage)
//                
//                DispatchQueue.main.async {
//                    // Only update afterImage if there's no ongoing processing
//                    if self.beforeImage == downsizedImage {
//                        self.afterImage = resultImage
//                    }
//                    self.isProcessing = false
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.errorMessage = "Processing failed: \(error.localizedDescription)"
//                    self.isProcessing = false
//                }
//            }
//        }
//    }
//
//    /// Debounce function to avoid multiple updates.
//    func debounceImageProcessing(newImage: UIImage?) {
//        debounceTimer?.invalidate() // Cancel any previous timer
//        
//        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//            if let image = newImage {
//                self.processImage(image)
//            }
//        }
//    }
//
//    /// Simulates image processing (could be a real transformation).
//    private func performProcessing(image: UIImage) throws -> UIImage {
//        guard let ciImage = CIImage(image: image) else {
//            throw NSError(domain: "ImageTransformation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to CIImage."])
//        }
//        
//        // Correct filter initialization: use the string filter name for CISepiaTone
//        guard let filter = CIFilter(name: "CISepiaTone") else {
//            throw NSError(domain: "ImageTransformation", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize CISepiaTone filter."])
//        }
//        
//        filter.setValue(ciImage, forKey: kCIInputImageKey)
//        filter.setValue(0.8, forKey: kCIInputIntensityKey) // Adjust intensity if needed
//        
//        guard let outputImage = filter.outputImage else {
//            throw NSError(domain: "ImageTransformation", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to apply filter."])
//        }
//        
//        let context = CIContext()
//        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
//            throw NSError(domain: "ImageTransformation", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage from CIImage."])
//        }
//        
//        return UIImage(cgImage: cgImage)
//    }
//
//    /// Reduces the image size to make processing more efficient.
//    private func downsized(image: UIImage?, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
//        guard let image = image else { return nil }
//        let newWidth = UIScreen.main.bounds.width * scale
//        let newHeight = UIScreen.main.bounds.width * image.size.height * scale / image.size.width
//        return image.resizeImage(to: CGSize(width: newWidth, height: newHeight))
//    }
//}


import SwiftUI
import Vision
import ImageIO

@MainActor
class SummaryViewModel: ObservableObject {
    @Published var beforeImage: UIImage?
    @Published var afterImage: UIImage?
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private let imageTransformViewModel = ImageTransformViewModel()
    private var debounceTimer: Timer?

    /// Processes the given image.
    func processImage(_ image: UIImage) {
        guard let downsizedImage = downsized(image: image) else { return }

        // Check if the image is already being processed
        if isProcessing { return }

        beforeImage = downsizedImage
        isProcessing = true

        Task {
            do {
                guard let originalImageBase64 = downsizedImage.toBase64() else {
                    throw NSError(domain: "Image Encoding Error", code: 0, userInfo: nil)
                }

                // Use the same image as a mask for now
                let maskImageBase64 = originalImageBase64

                let transformedImageBase64 = try await uploadTransformImage(
                    originalImage: originalImageBase64,
                    maskImage: maskImageBase64
                )

                if let resultImage = UIImage.fromBase64(transformedImageBase64) {
                    if self.beforeImage == downsizedImage {
                        self.afterImage = resultImage
                    }
                } else {
                    throw NSError(domain: "Image Decoding Error", code: 0, userInfo: nil)
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }

            self.isProcessing = false
        }
    }

    /// Debounce function to avoid multiple updates.
    func debounceImageProcessing(newImage: UIImage?) {
        debounceTimer?.invalidate() // Cancel any previous timer

        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if let image = newImage {
                self.processImage(image)
            }
        }
    }

    /// API call to transform the image.
    private func uploadTransformImage(originalImage: String, maskImage: String) async throws -> String {
//        let userInstance = UserData.getInstance()
        let parameters: [String: Any] = [
//            "prompt": "lose \(userInstance.user.goalDetails.fatLoss!) kg and gain \(userInstance.user.goalDetails.muscleGain!) kg muscle",
            "prompt": "lose 10 kg and gain 7 kg muscle",
            "negative_prompt": "clothes,cartoon,disfigured,blurry,nude",
            "image": originalImage,
            "mask_image": maskImage,
            "model": "realistic-vision-v5-1-inpainting",
            "seed": 10,
            "steps": 50,
            "strength": 0.8,
            "schedular": "euler",
            "guidance": 7,
            "width": 768,
            "height": 960
        ]

        guard let url = URL(string: "https://api.getimg.ai/v1/stable-diffusion/inpaint") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let response = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let base64Image = response["output_image"] as? String else {
            throw NSError(domain: "Invalid Response", code: 0, userInfo: nil)
        }

        return base64Image
    }

    /// Simulates image processing (optional fallback).
    private func performProcessing(image: UIImage) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw NSError(domain: "ImageTransformation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to CIImage."])
        }

        guard let filter = CIFilter(name: "CISepiaTone") else {
            throw NSError(domain: "ImageTransformation", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize CISepiaTone filter."])
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: kCIInputIntensityKey)

        guard let outputImage = filter.outputImage else {
            throw NSError(domain: "ImageTransformation", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to apply filter."])
        }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw NSError(domain: "ImageTransformation", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage from CIImage."])
        }

        return UIImage(cgImage: cgImage)
    }

    /// Reduces the image size to make processing more efficient.
    private func downsized(image: UIImage?, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard let image = image else { return nil }
        let newWidth = UIScreen.main.bounds.width * scale
        let newHeight = newWidth * image.size.height / image.size.width
        return image.resizeImage(to: CGSize(width: newWidth, height: newHeight))
    }
}
