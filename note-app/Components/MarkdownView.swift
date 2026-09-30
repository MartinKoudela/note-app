import SwiftUI

struct MarkdownView: View {
    @Binding var text: String

    private var blocks: [MarkdownBlock] {
        MarkdownBlock.parse(text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(blocks) { block in
                view(for: block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
    }

    @ViewBuilder
    private func view(for block: MarkdownBlock) -> some View {
        switch block.kind {
        case .heading(let level, let content):
            Text(inline(content))
                .font(headingFont(level))
                .fontWeight(level <= 2 ? .bold : .semibold)
                .padding(.top, level <= 2 ? 8 : 4)
                .accessibilityAddTraits(.isHeader)

        case .paragraph(let content):
            Text(inline(content))

        case .bullet(let content, let indent):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("•")
                    .foregroundStyle(.secondary)
                Text(inline(content))
            }
            .padding(.leading, CGFloat(indent) * 18)

        case .numbered(let number, let content, let indent):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(number).")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                Text(inline(content))
            }
            .padding(.leading, CGFloat(indent) * 18)

        case .task(let isDone, let content, let indent, let line):
            Button {
                toggleTask(atLine: line)
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isDone ? Color.accentColor : Color.secondary)
                        .contentTransition(.symbolEffect(.replace))
                    Text(inline(content))
                        .strikethrough(isDone)
                        .foregroundStyle(isDone ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, CGFloat(indent) * 18)
            .accessibilityAddTraits(isDone ? .isSelected : [])

        case .quote(let content):
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.tint)
                    .frame(width: 3)
                Text(inline(content))
                    .foregroundStyle(.secondary)
                    .italic()
            }
            .fixedSize(horizontal: false, vertical: true)

        case .code(let language, let code):
            VStack(alignment: .leading, spacing: 6) {
                if !language.isEmpty {
                    Text(language)
                        .font(.caption2.weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(code)
                        .font(.system(.callout, design: .monospaced))
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.fill.tertiary, in: .rect(cornerRadius: 10, style: .continuous))

        case .rule:
            Divider()
                .padding(.vertical, 4)
        }
    }

    private func headingFont(_ level: Int) -> Font {
        switch level {
        case 1: .title
        case 2: .title2
        case 3: .title3
        default: .headline
        }
    }

    private func inline(_ content: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: content, options: options)) ?? AttributedString(content)
    }

    private func toggleTask(atLine line: Int) {
        var lines = text.components(separatedBy: "\n")
        guard lines.indices.contains(line) else { return }

        let current = lines[line]
        if let range = current.range(of: "[ ]") {
            lines[line] = current.replacingCharacters(in: range, with: "[x]")
        } else if let range = current.range(of: "[x]", options: .caseInsensitive) {
            lines[line] = current.replacingCharacters(in: range, with: "[ ]")
        }

        withAnimation(.snappy) {
            text = lines.joined(separator: "\n")
        }
    }
}

struct MarkdownBlock: Identifiable {
    enum Kind {
        case heading(level: Int, text: String)
        case paragraph(String)
        case bullet(String, indent: Int)
        case numbered(Int, String, indent: Int)
        case task(isDone: Bool, text: String, indent: Int, line: Int)
        case quote(String)
        case code(language: String, code: String)
        case rule
    }

    let id: Int
    let kind: Kind

    static func parse(_ text: String) -> [MarkdownBlock] {
        let lines = text.components(separatedBy: "\n")
        var blocks: [MarkdownBlock] = []
        var paragraph: [String] = []
        var index = 0

        func append(_ kind: Kind, at line: Int) {
            blocks.append(MarkdownBlock(id: line, kind: kind))
        }

        func flushParagraph(endingAt line: Int) {
            guard !paragraph.isEmpty else { return }
            append(.paragraph(paragraph.joined(separator: "\n")), at: line - paragraph.count)
            paragraph.removeAll()
        }

        while index < lines.count {
            let rawLine = lines[index]
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            let indent = (rawLine.prefix { $0 == " " }.count) / 2

            if trimmed.hasPrefix("```") {
                flushParagraph(endingAt: index)
                let start = index
                let language = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                index += 1
                while index < lines.count, !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[index])
                    index += 1
                }
                append(.code(language: language, code: codeLines.joined(separator: "\n")), at: start)
                index += 1
                continue
            }

            if trimmed.isEmpty {
                flushParagraph(endingAt: index)
            } else if let heading = headingLevel(trimmed) {
                flushParagraph(endingAt: index)
                append(.heading(level: heading, text: String(trimmed.dropFirst(heading + 1))), at: index)
            } else if ["---", "***", "___"].contains(trimmed) {
                flushParagraph(endingAt: index)
                append(.rule, at: index)
            } else if let task = taskItem(trimmed) {
                flushParagraph(endingAt: index)
                append(.task(isDone: task.isDone, text: task.text, indent: indent, line: index), at: index)
            } else if let bullet = bulletText(trimmed) {
                flushParagraph(endingAt: index)
                append(.bullet(bullet, indent: indent), at: index)
            } else if let numbered = numberedItem(trimmed) {
                flushParagraph(endingAt: index)
                append(.numbered(numbered.number, numbered.text, indent: indent), at: index)
            } else if trimmed.hasPrefix(">") {
                flushParagraph(endingAt: index)
                append(.quote(String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)), at: index)
            } else {
                paragraph.append(trimmed)
            }
            index += 1
        }
        flushParagraph(endingAt: index)
        return blocks
    }

    private static func headingLevel(_ line: String) -> Int? {
        let hashes = line.prefix { $0 == "#" }.count
        guard (1...6).contains(hashes), line.dropFirst(hashes).first == " " else { return nil }
        return hashes
    }

    private static func taskItem(_ line: String) -> (isDone: Bool, text: String)? {
        for marker in ["- ", "* ", "+ "] where line.hasPrefix(marker) {
            let rest = line.dropFirst(marker.count)
            if rest.hasPrefix("[ ] ") || rest == "[ ]" {
                return (false, String(rest.dropFirst(3)).trimmingCharacters(in: .whitespaces))
            }
            if rest.lowercased().hasPrefix("[x] ") || rest.lowercased() == "[x]" {
                return (true, String(rest.dropFirst(3)).trimmingCharacters(in: .whitespaces))
            }
        }
        return nil
    }

    private static func bulletText(_ line: String) -> String? {
        for marker in ["- ", "* ", "+ "] where line.hasPrefix(marker) {
            return String(line.dropFirst(marker.count))
        }
        return nil
    }

    private static func numberedItem(_ line: String) -> (number: Int, text: String)? {
        let digits = line.prefix { $0.isNumber }
        guard !digits.isEmpty,
              let number = Int(digits),
              line.dropFirst(digits.count).hasPrefix(". ")
        else { return nil }
        return (number, String(line.dropFirst(digits.count + 2)))
    }
}

#Preview {
    @Previewable @State var text = """
    # Backlog
    A **fast** notes app with `markdown`.

    ## Todo
    - [x] Models
    - [ ] Pages

    > Ship it.

    ```swift
    print("hello")
    ```
    """
    ScrollView {
        MarkdownView(text: $text)
            .padding()
    }
}
