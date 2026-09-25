import SwiftUI

struct SearchView: View {
    @State private var query = ""

    var body: some View {
        NavigationStack {
            Text("Search")
                .navigationTitle("Search")
                .searchable(text: $query)
        }
    }
}

#Preview {
    SearchView()
}
