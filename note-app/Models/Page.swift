import Foundation
import SwiftData

@Model
final class Page {
    var title: String = ""
    var content: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var lastOpenedAt: Date?
    var sortOrder: Int = 0
    var deletedAt: Date?
    var isArchived: Bool = false

    var project: Project?
    var parent: Page?

    @Relationship(deleteRule: .cascade, inverse: \Page.parent)
    var children: [Page] = []

    init(title: String = "", project: Project? = nil, parent: Page? = nil) {
        self.title = title
        self.project = project
        self.parent = parent
    }
}

extension Page {
    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled" : trimmed
    }

    var activeChildren: [Page] {
        children
            .filter { $0.deletedAt == nil && !$0.isArchived }
            .sorted { ($0.sortOrder, $0.createdAt) < ($1.sortOrder, $1.createdAt) }
    }

    var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        activeChildren.isEmpty
    }

    var isVisible: Bool {
        deletedAt == nil && !isArchived && parent?.isVisible != false && project?.deletedAt == nil
    }

    var systemImage: String {
        if !activeChildren.isEmpty && content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "folder"
        }
        if title.localizedCaseInsensitiveContains("readme") {
            return "book.pages"
        }
        return "doc.text"
    }

    var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    var checklistProgress: (done: Int, total: Int)? {
        let lines = content.split(whereSeparator: \.isNewline).map { $0.trimmingCharacters(in: .whitespaces) }
        let open = lines.filter { $0.hasPrefix("- [ ]") || $0.hasPrefix("* [ ]") }.count
        let done = lines.filter { $0.lowercased().hasPrefix("- [x]") || $0.lowercased().hasPrefix("* [x]") }.count
        let total = open + done
        return total > 0 ? (done, total) : nil
    }

    var nextChildSortOrder: Int {
        (children.map(\.sortOrder).max() ?? -1) + 1
    }
}
