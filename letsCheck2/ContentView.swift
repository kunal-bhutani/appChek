import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            CaptureView() // Make sure CaptureView has proper navigation to SummaryView
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
