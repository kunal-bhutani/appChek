
import SwiftUI

struct ImageView: View {
    let image: UIImage?
    let title: String
    var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Image(uiImage: image ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
