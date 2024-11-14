
import SwiftUI

struct CaptureView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SummaryViewModel()
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack {
            Text("Take a Picture")
                .font(.title)
                .padding()
            
            Button(action: {
                showingImagePicker = true
            }) {
                Text("Open Camera")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            if viewModel.beforeImage != nil {
                Text("Processing...")
                    .padding()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(sourceType: .camera, selectedImage: $viewModel.beforeImage)
        }
        .onChange(of: viewModel.beforeImage) { newImage in
            if let image = newImage {
                viewModel.processImage(image)
            }
        }
        .onChange(of: viewModel.afterImage) { _ in
            if viewModel.afterImage != nil {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationDestination(isPresented: .constant(viewModel.afterImage != nil)) {
            SummaryView(viewModel: viewModel)
        }
    }
}
