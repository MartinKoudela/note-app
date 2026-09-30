import SwiftUI
import SwiftData
import UIKit

struct PageView: View {
    @Bindable var page: Page

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var isEditing: Bool
    @State private var selection: TextSelection?
    @State private var newSubpage: Page?
    @State private var showDeleteConfirmation = false
    @FocusState private var focus: Field?

    private enum Field {
        case title, content
    }

    init(page: Page) {
        _page = Bindable(page)
        _isEditing = State(initialValue: page.content.isEmpty)
    }

    private var exportText: String {
        let body = page.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if body.hasPrefix("# ") {
            return body
        }
        return "# \(page.displayTitle)\n\n\(body)"
    }

    private var breadcrumb: String {
        var parts: [String] = []
        var parent = page.parent
        while let current = parent {
            parts.insert(current.displayTitle, at: 0)
            parent = current.parent
        }
        if let project = page.project {
            parts.insert(project.name, at: 0)
        }
        return parts.joined(separator: " / ")
    }

    var body: some View {
        Group {
            if isEditing {
                editor
            } else {
                preview
            }
        }
        .navigationTitle(page.displayTitle)
        .navigationSubtitle(breadcrumb)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if isEditing && focus == .content {
                markdownBar
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: focus)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.snappy) {
                        isEditing.toggle()
                    }
                    focus = isEditing ? .content : nil
                } label: {
                    Label(isEditing ? "Preview" : "Edit", systemImage: isEditing ? "eye" : "square.and.pencil")
                }
            }

            ToolbarSpacer(.fixed, placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis") {
                    Button("New Subpage", systemImage: "doc.badge.plus") {
                        createSubpage()
                    }

                    Divider()

                    ShareLink(item: exportText, subject: Text(page.displayTitle), preview: SharePreview(page.displayTitle)) {
                        Label("Share Markdown", systemImage: "square.and.arrow.up")
                    }

                    Button("Copy Markdown", systemImage: "doc.on.doc") {
                        UIPasteboard.general.string = exportText
                    }

                    Divider()

                    Button("Archive Page", systemImage: MoreDestination.archive.systemImage) {
                        page.isArchived = true
                        dismiss()
                    }

                    Button("Delete Page", systemImage: MoreDestination.bin.systemImage, role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
        }
        .confirmationDialog("Move \"\(page.displayTitle)\" to Bin?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Move to Bin", role: .destructive) {
                page.deletedAt = .now
                dismiss()
            }
        } message: {
            if !page.activeChildren.isEmpty {
                Text("Its subpages will be moved too.")
            }
        }
        .navigationDestination(item: $newSubpage) { subpage in
            PageView(page: subpage)
        }
        .onAppear {
            page.lastOpenedAt = .now
            if isEditing {
                focus = page.title.isEmpty ? .title : .content
            }
        }
        .onDisappear {
            if page.isEmpty && newSubpage == nil {
                modelContext.delete(page)
            }
        }
        .onChange(of: page.title) {
            page.updatedAt = .now
        }
        .onChange(of: page.content) { oldValue, newValue in
            page.updatedAt = .now
            continueListIfNeeded(old: oldValue, new: newValue)
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $page.title)
                .font(.title.bold())
                .focused($focus, equals: .title)
                .submitLabel(.next)
                .onSubmit { focus = .content }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 4)

            ZStack(alignment: .topLeading) {
                if page.content.isEmpty {
                    Text("Start writing… Markdown supported")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $page.content, selection: $selection)
                    .font(.system(.body, design: .monospaced))
                    .focused($focus, equals: .content)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 15)
            }

            if focus != .content {
                footer
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
            }
        }
    }

    private var preview: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(page.displayTitle)
                    .font(.largeTitle.bold())
                    .foregroundStyle(page.title.isEmpty ? .secondary : .primary)

                footer

                if page.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        withAnimation(.snappy) { isEditing = true }
                        focus = .content
                    } label: {
                        Label("Start writing", systemImage: "square.and.pencil")
                    }
                    .buttonStyle(.bordered)
                } else {
                    MarkdownView(text: $page.content)
                }

                if !page.activeChildren.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pages")
                            .font(.headline)
                            .padding(.top, 12)

                        ForEach(page.activeChildren) { child in
                            NavigationLink(value: child) {
                                PageRow(page: child)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Text(page.wordCount == 1 ? "1 word" : "\(page.wordCount) words")
            Text("·")
            Text("Edited \(page.updatedAt.formatted(.relative(presentation: .named)))")
            if let progress = page.checklistProgress {
                Text("·")
                Label("\(progress.done)/\(progress.total)", systemImage: "checklist")
                    .labelStyle(.titleAndIcon)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .monospacedDigit()
    }

    private var markdownBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                barButton("Heading", systemImage: "number") { cycleHeading() }
                barButton("Bold", systemImage: "bold") { wrap("**", "**") }
                barButton("Italic", systemImage: "italic") { wrap("_", "_") }
                barButton("Strikethrough", systemImage: "strikethrough") { wrap("~~", "~~") }
                barButton("Checklist", systemImage: "checklist") { prefixLine("- [ ] ") }
                barButton("List", systemImage: "list.bullet") { prefixLine("- ") }
                barButton("Numbered List", systemImage: "list.number") { toggleNumberedList() }
                barButton("Quote", systemImage: "text.quote") { prefixLine("> ") }
                barButton("Inline Code", systemImage: "chevron.left.forwardslash.chevron.right") { wrap("`", "`") }
                barButton("Code Block", systemImage: "curlybraces") { wrap("```\n", "\n```") }
                barButton("Link", systemImage: "link") { wrap("[", "](https://)") }
                barButton("Divider", systemImage: "minus") { prefixLine("---\n") }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 48)
        .glassEffect(.regular.interactive(), in: .capsule)
    }

    private func barButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.medium))
                .frame(width: 40, height: 40)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func cursorRange(in text: String) -> Range<Int> {
        guard let selection,
              case .selection(let range) = selection.indices,
              let lower = range.lowerBound.samePosition(in: text),
              let upper = range.upperBound.samePosition(in: text)
        else { return text.count..<text.count }

        return text.distance(from: text.startIndex, to: lower)..<text.distance(from: text.startIndex, to: upper)
    }

    private func wrap(_ prefix: String, _ suffix: String) {
        var text = page.content
        let range = cursorRange(in: text)
        let lower = text.index(text.startIndex, offsetBy: range.lowerBound)
        let upper = text.index(text.startIndex, offsetBy: range.upperBound)
        let selected = String(text[lower..<upper])

        text.replaceSubrange(lower..<upper, with: prefix + selected + suffix)
        page.content = text

        let cursor = range.lowerBound + prefix.count + selected.count
        selection = TextSelection(insertionPoint: text.index(text.startIndex, offsetBy: cursor))
    }

    private func prefixLine(_ prefix: String) {
        var text = page.content
        let range = cursorRange(in: text)
        let cursor = text.index(text.startIndex, offsetBy: range.lowerBound)
        let lineStart = text[..<cursor].lastIndex(of: "\n").map { text.index(after: $0) } ?? text.startIndex

        text.insert(contentsOf: prefix, at: lineStart)
        page.content = text

        let newCursor = range.lowerBound + prefix.count
        selection = TextSelection(insertionPoint: text.index(text.startIndex, offsetBy: newCursor))
    }

    private func toggleNumberedList() {
        var text = page.content
        let range = cursorRange(in: text)
        let cursor = text.index(text.startIndex, offsetBy: range.lowerBound)
        let lineStart = text[..<cursor].lastIndex(of: "\n").map { text.index(after: $0) } ?? text.startIndex
        let line = String(text[lineStart...].prefix { $0 != "\n" })
        let indent = line.prefix { $0 == " " }.count
        let markerStart = text.index(lineStart, offsetBy: indent)
        let lineStartOffset = text.distance(from: text.startIndex, to: lineStart)
        
        let newCursor: Int
        if let marker = ListMarker(line: line), case .numbered = marker.kind {
            let markerEnd = text.index(markerStart, offsetBy: marker.prefix.count)
            text.removeSubrange(markerStart..<markerEnd)
            newCursor = max(lineStartOffset + indent, range.lowerBound - marker.prefix.count)
        } else {
            let previous = previousLine(before: lineStart, in: text)
            var number = 1
            if let previous,
               let marker = ListMarker(line: previous),
               case .numbered(let previousNumber) = marker.kind,
               marker.indent == indent {
                number = previousNumber + 1
            }
            let prefix = "\(number). "
            text.insert(contentsOf: prefix, at: markerStart)
            newCursor = range.lowerBound + prefix.count
        }
        
        page.content = text
        selection = TextSelection(insertionPoint: text.index(text.startIndex, offsetBy: min(newCursor, text.count)))
    }
    
    private func previousLine(before lineStart: String.Index, in text: String) -> String? {
        guard lineStart > text.startIndex else { return nil }
        let newline = text.index(before: lineStart)
        let start = text[..<newline].lastIndex(of: "\n").map { text.index(after: $0) } ?? text.startIndex
        return String(text[start..<newline])
    }
    
    private func continueListIfNeeded(old: String, new: String) {
        guard new.count == old.count + 1 else { return }
        
        let insertedOffset = zip(old, new).prefix { $0 == $1 }.count
        let insertedIndex = new.index(new.startIndex, offsetBy: insertedOffset)
        guard new[insertedIndex] == "\n" else { return }
        
        let lineStart = new[..<insertedIndex].lastIndex(of: "\n").map { new.index(after: $0) } ?? new.startIndex
        let line = String(new[lineStart..<insertedIndex])
        guard let marker = ListMarker(line: line) else { return }
        
        var text = new
        let lineStartOffset = new.distance(from: new.startIndex, to: lineStart)
        
        if marker.isEmptyItem(line) {
            let end = text.index(after: insertedIndex)
            text.removeSubrange(lineStart..<end)
            page.content = text
            selection = TextSelection(insertionPoint: text.index(text.startIndex, offsetBy: lineStartOffset))
            return
        }
        
        let continuation = String(repeating: " ", count: marker.indent) + marker.next
        let insertAt = text.index(after: text.index(text.startIndex, offsetBy: insertedOffset))
        text.insert(contentsOf: continuation, at: insertAt)
        page.content = text
        
        let cursor = insertedOffset + 1 + continuation.count
        selection = TextSelection(insertionPoint: text.index(text.startIndex, offsetBy: cursor))
    }
    
    private func cycleHeading() {
        var text = page.content
        let range = cursorRange(in: text)
        let cursor = text.index(text.startIndex, offsetBy: range.lowerBound)
        let lineStart = text[..<cursor].lastIndex(of: "\n").map { text.index(after: $0) } ?? text.startIndex
        let line = text[lineStart...].prefix { $0 != "\n" }
        let hashes = line.prefix { $0 == "#" }.count
        let isHeading = (1...6).contains(hashes) && line.dropFirst(hashes).first == " "
        let lineStartOffset = text.distance(from: text.startIndex, to: lineStart)

        let offsetChange: Int
        if isHeading && hashes < 6 {
            text.insert("#", at: lineStart)
            offsetChange = 1
        } else if isHeading {
            let end = text.index(lineStart, offsetBy: hashes + 1)
            text.removeSubrange(lineStart..<end)
            offsetChange = -(hashes + 1)
        } else {
            text.insert(contentsOf: "# ", at: lineStart)
            offsetChange = 2
        }
        page.content = text

        let newCursor = min(max(lineStartOffset, range.lowerBound + offsetChange), text.count)
        selection = TextSelection(insertionPoint: text.index(text.startIndex, offsetBy: newCursor))
    }

    private func createSubpage() {
        let subpage = Page(project: page.project, parent: page)
        subpage.sortOrder = page.nextChildSortOrder
        modelContext.insert(subpage)
        newSubpage = subpage
    }
}

#Preview {
    NavigationStack {
        PageView(page: Page(title: "README"))
    }
    .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}

private struct ListMarker {
    enum Kind {
        case bullet(Character)
        case task
        case numbered(Int)
        case quote
    }
    
    let kind: Kind
    let indent: Int
    let prefix: String
    
    init?(line: String) {
        indent = line.prefix { $0 == " " }.count
        let body = line.dropFirst(indent)
        
        for marker in ["- [ ] ", "- [x] ", "- [X] ", "* [ ] ", "* [x] "] where body.hasPrefix(marker) {
            kind = .task
            prefix = marker
            return
        }
        
        for marker in ["- ", "* ", "+ "] where body.hasPrefix(marker) {
            kind = .bullet(marker.first!)
            prefix = marker
            return
        }
        
        let digits = body.prefix { $0.isNumber }
        if !digits.isEmpty, let number = Int(digits), body.dropFirst(digits.count).hasPrefix(". ") {
            kind = .numbered(number)
            prefix = "\(digits). "
            return
        }
        
        if body.hasPrefix("> ") {
            kind = .quote
            prefix = "> "
            return
        }
        
        return nil
    }
    
    var next: String {
        switch kind {
        case .bullet(let character): "\(character) "
        case .task: "- [ ] "
        case .numbered(let number): "\(number + 1). "
        case .quote: "> "
        }
    }
    
    func isEmptyItem(_ line: String) -> Bool {
        line.dropFirst(indent + prefix.count).trimmingCharacters(in: .whitespaces).isEmpty
    }
}
