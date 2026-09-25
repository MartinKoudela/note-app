import SwiftUI

struct SearchView: View {
    @State private var query = ""
    
    var body: some View {
        NavigationStack {
            Text("Search")
                .navigationTitle(AppTab.search.title)
                .searchable(text: $query)
        }
    }
}

#Preview {
    SearchView()
}
