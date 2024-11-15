import Foundation

@MainActor
class ImageTransformViewModel: ObservableObject {
    private let apiKey = "Bearer key-9YQGW94MhOdVrzAuaLaYIQTIP5AeJse50PATVLR7EY0xn19p33vS7p16eaVeTHRk5aIqOiLGq5hiakbiSENaaqxkbgHp64I"  // Replace with your actual API key
    
    func transformImage(originalImage: String, maskImage: String) async throws -> String {
        let parameters = ImageTransformParameters(
            prompt: "enhance photo quality",
            negativePrompt: "blur, distortion",
            image: originalImage,
            maskImage: maskImage,
            model: "realistic-vision-v5-1-inpainting",  // Update with your actual model name
            seed: 10,
            steps: 50,
            strength: 0.8,
            schedular: "euler",
            guidance: 7,
            width: 768,
            height: 960
        )
        
        guard let url = URL(string: "https://api.getimg.ai/v1/stable-diffusion/inpaint") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 1000
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "authorization")
        request.httpBody = try JSONEncoder().encode(parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let decodedResponse = try JSONDecoder().decode(ImageTransformResponse.self, from: data)
        return decodedResponse.image
    }
}
