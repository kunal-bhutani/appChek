// CaptureView.swift
import SwiftUI

struct CaptureView: View {
    @StateObject private var viewModel = SummaryViewModel()
    @State private var showingImagePicker = false
    @State private var isNavigatingToSummary = false
    
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
            
            if viewModel.isProcessing {
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
        .onChange(of: viewModel.afterImage) { newImage in
            if newImage != nil {
                isNavigatingToSummary = true
            }
        }
        .navigationDestination(isPresented: $isNavigatingToSummary) {
            SummaryView(viewModel: viewModel)
        }
    }
}
