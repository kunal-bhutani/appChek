import Foundation

struct ImageTransformParameters: Encodable {
    let prompt: String
    let negativePrompt: String
    let image: String
    let maskImage: String
    let model: String
    let seed: Int
    let steps: Int
    let strength: Double
    let schedular: String
    let guidance: Int
    let width: Int
    let height: Int
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case negativePrompt = "negative_prompt"
        case image
        case maskImage = "mask_image"
        case model, seed, steps, strength, schedular, guidance, width, height
    }
}

struct ImageTransformResponse: Decodable {
    let image: String
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case noData
    case apiError(String)
}
