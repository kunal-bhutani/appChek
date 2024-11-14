import SwiftUI
import UIKit

class SummaryViewModel: ObservableObject {
    @Published var beforeImage: UIImage?
    @Published var afterImage: UIImage?
    @Published var isProcessing = false
    
    func processImage(_ image: UIImage) {
        self.beforeImage = image
        self.isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.afterImage = image // Replace this with the actual processed image in a real case
            self.isProcessing = false
        }
    }
}
