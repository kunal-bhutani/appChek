import SwiftUI
import Vision
import ImageIO

@MainActor
class SummaryViewModel: ObservableObject {
    @Published var beforeImage: UIImage?
    @Published var afterImage: UIImage?
    @Published var isProcessing = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var errorMessage: String?
    
    private let visionQueue = DispatchQueue(label: "com.app.vision", qos: .userInitiated)
    private let imageTransformViewModel = ImageTransformViewModel()
    
    func processImage(_ image: UIImage) {
        guard let downsizedImage = downsized(image: image) else { return }
        beforeImage = downsizedImage
        isProcessing = true
        
        Task {
            do {
                guard let originalImageBase64 = downsizedImage.toBase64() else {
                    throw NetworkError.noData
                }
                
                // For testing, use the same image as mask
                // In production, you should generate a proper mask
                let maskImageBase64 = originalImageBase64
                
                let transformedImageBase64 = try await imageTransformViewModel.transformImage(
                    originalImage: originalImageBase64,
                    maskImage: maskImageBase64
                )
                
                if let resultImage = UIImage.fromBase64(transformedImageBase64) {
                    await MainActor.run {
                        self.afterImage = resultImage
                        self.isProcessing = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func downsized(image: UIImage?, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        guard let image = image else { return nil }
        let newWidth = UIScreen.main.bounds.width * scale
        let newHeight = UIScreen.main.bounds.width * image.size.height * scale / image.size.width
        return image.resizeImage(to: CGSize(width: newWidth, height: newHeight))
    }
}
