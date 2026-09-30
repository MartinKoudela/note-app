import SwiftUI

struct PageTreeRow: View {
    let page: Page

    @State private var isExpanded = false

    var body: some View {
        if page.activeChildren.isEmpty {
            link
        } else {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(page.activeChildren) { child in
                    PageTreeRow(page: child)
                }
            } label: {
                link
            }
        }
    }

    private var link: some View {
        NavigationLink(value: page) {
            PageRow(page: page)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                page.deletedAt = .now
            } label: {
                Label(MoreDestination.bin.title, systemImage: MoreDestination.bin.systemImage)
            }
            
            Button {
                page.isArchived = true
            } label: {
                Label(MoreDestination.archive.title, systemImage: MoreDestination.archive.systemImage)
            }
            .tint(.indigo)
        }
        .selectionDisabled()
        .listSectionSeparator(.hidden)
    }
}
