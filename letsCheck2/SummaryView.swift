import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: SummaryViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                
                VStack(spacing: 12) {
                    Text("Body Transformation")
                        .font(.title2)
                        .bold()
                    
                    HStack(spacing: 16) {
                        ImageView(
                            image: viewModel.beforeImage,
                            title: "Before"
                        )
                        
                        ImageView(
                            image: viewModel.afterImage,
                            title: "After",
                            isLoading: viewModel.isProcessing
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
        }
        .navigationTitle("Summary")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
