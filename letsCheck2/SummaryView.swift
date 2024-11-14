import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: SummaryViewModel

    var body: some View {
        VStack {
            Text("Summary")
                .font(.largeTitle)
                .bold()
                .padding()
            
            HStack(spacing: 16) {
                ImageView(image: viewModel.beforeImage, title: "Before")
                ImageView(image: viewModel.afterImage, title: "After", isLoading: viewModel.isProcessing)
            }
            .padding()
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}
