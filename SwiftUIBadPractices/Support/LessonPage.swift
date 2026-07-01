import SwiftUI
import Splash

#if os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

/// Reusable layout for a single lesson.
///
/// Every lesson shows a short explanation, then two examples: the
/// "Avoid" version and the "Prefer" version, each with its key code.
/// When a lesson has a visible runtime difference, it also supplies a
/// live demo for each side via the `avoidDemo`/`preferDemo` builders;
/// lessons whose behavior is identical on screen omit them and stay
/// code-only.
struct LessonPage<AvoidDemo: View, PreferDemo: View>: View {
    let title: String
    let explanation: String
    let avoidCode: String
    let preferCode: String
    let showsDemos: Bool
    let avoidDemo: AvoidDemo
    let preferDemo: PreferDemo

    init(
        title: String,
        explanation: String,
        avoidCode: String,
        preferCode: String,
        @ViewBuilder avoidDemo: () -> AvoidDemo,
        @ViewBuilder preferDemo: () -> PreferDemo
    ) {
        self.title = title
        self.explanation = explanation
        self.avoidCode = avoidCode
        self.preferCode = preferCode
        self.showsDemos = true
        self.avoidDemo = avoidDemo()
        self.preferDemo = preferDemo()
    }

    var body: some View {
        ScrollView {
            lessonContent
                // Match the navigation bar's large-title leading inset (20pt
                // on iPad) so the body and cards align with the title.
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .navigationTitle(title)
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Export Image", systemImage: "square.and.arrow.up") {
                    exportImage()
                }
            }
        }
        #endif
    }

    /// The visible body of a lesson: the explanation followed by the two
    /// example cards. Shared by the on-screen view and the image export so
    /// the exported image matches exactly what's rendered on screen.
    private var lessonContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            InlineCodeText(explanation)

            LessonExample(
                label: "Avoid",
                tint: .avoid,
                systemImage: "xmark.octagon.fill",
                code: avoidCode,
                showsDemo: showsDemos
            ) {
                avoidDemo
            }

            LessonExample(
                label: "Prefer",
                tint: .prefer,
                systemImage: "checkmark.seal.fill",
                code: preferCode,
                showsDemo: showsDemos
            ) {
                preferDemo
            }
        }
    }

    #if os(macOS)
    /// The lesson laid out for export: the title above the same content
    /// shown on screen, on a light background at a fixed width. Pinned to the
    /// light color scheme so the image looks the same no matter the app's
    /// current appearance.
    private var exportContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title)
                .font(.largeTitle.weight(.bold))

            lessonContent
        }
        .padding(24)
        .frame(width: 760, alignment: .leading)
        .background(Color(white: 0.95))
        .environment(\.colorScheme, .light)
    }

    /// Renders `exportContent` to a PNG at 2x and prompts for a save location.
    @MainActor
    private func exportImage() {
        let renderer = ImageRenderer(content: exportContent)
        renderer.scale = 2

        guard
            let image = renderer.nsImage,
            let tiff = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let png = bitmap.representation(using: .png, properties: [:])
        else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "\(title).png"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? png.write(to: url)
    }
    #endif
}

extension LessonPage where AvoidDemo == EmptyView, PreferDemo == EmptyView {
    /// Code-only lesson: no live demo (used when the "Avoid" and "Prefer"
    /// versions render identically and a demo would only confuse).
    init(
        title: String,
        explanation: String,
        avoidCode: String,
        preferCode: String
    ) {
        self.title = title
        self.explanation = explanation
        self.avoidCode = avoidCode
        self.preferCode = preferCode
        self.showsDemos = false
        self.avoidDemo = EmptyView()
        self.preferDemo = EmptyView()
    }
}

/// Text for lesson explanations, with inline code spans delimited by
/// backquotes rendered as small inline code chips.
private struct InlineCodeText: View {
    private let runs: [InlineCodeRun]

    init(_ source: String) {
        self.runs = Self.runs(in: source)
    }

    var body: some View {
        InlineCodeFlowLayout(verticalSpacing: 0) {
            ForEach(Array(runs.enumerated()), id: \.offset) { _, run in
                if run.isLineBreak {
                    Text(" ")
                        .font(.title3)
                        .hidden()
                        .layoutValue(key: InlineCodeLineBreakKey.self, value: true)
                } else if run.isCode {
                    Text(run.string)
                        .font(.system(.title3, design: .monospaced).weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                } else if run.isSpace {
                    Text(" ")
                        .font(.title3)
                } else {
                    Text(run.string)
                        .font(.title3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private static func runs(in source: String) -> [InlineCodeRun] {
        var runs: [InlineCodeRun] = []
        var current = ""
        var isCode = false

        for character in source {
            if character == "`" {
                append(current, isCode: isCode, to: &runs)
                current.removeAll(keepingCapacity: true)
                isCode.toggle()
            } else {
                current.append(character)
            }
        }

        if isCode {
            append("`" + current, isCode: false, to: &runs)
        } else {
            append(current, isCode: false, to: &runs)
        }

        return runs
    }

    private static func append(
        _ string: String,
        isCode: Bool,
        to runs: inout [InlineCodeRun]
    ) {
        guard !string.isEmpty else { return }

        if isCode {
            runs.append(InlineCodeRun(string: string, isCode: true))
        } else {
            appendPlainText(string, to: &runs)
        }
    }

    private static func appendPlainText(_ string: String, to runs: inout [InlineCodeRun]) {
        var current = ""

        for character in string {
            if character.isNewline {
                appendPlainToken(current, to: &runs)
                current.removeAll(keepingCapacity: true)
                runs.append(.lineBreak)
            } else if character.isWhitespace {
                appendPlainToken(current, to: &runs)
                current.removeAll(keepingCapacity: true)
                runs.append(.space)
            } else {
                current.append(character)
            }
        }

        appendPlainToken(current, to: &runs)
    }

    private static func appendPlainToken(_ string: String, to runs: inout [InlineCodeRun]) {
        guard !string.isEmpty else { return }
        runs.append(InlineCodeRun(string: string, isCode: false))
    }
}

private struct InlineCodeRun {
    let string: String
    let isCode: Bool
    var isSpace = false
    var isLineBreak = false

    static let space = InlineCodeRun(string: " ", isCode: false, isSpace: true)
    static let lineBreak = InlineCodeRun(string: "", isCode: false, isLineBreak: true)
}

nonisolated private struct InlineCodeLineBreakKey: LayoutValueKey {
    static let defaultValue = false
}

private struct InlineCodeFlowLayout: Layout {
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        arrangedSubviews(in: proposal.width, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let arrangement = arrangedSubviews(in: bounds.width, subviews: subviews)

        for placement in arrangement.placements {
            subviews[placement.index].place(
                at: CGPoint(
                    x: bounds.minX + placement.origin.x,
                    y: bounds.minY + placement.origin.y
                ),
                proposal: ProposedViewSize(placement.size)
            )
        }
    }

    private func arrangedSubviews(
        in proposedWidth: CGFloat?,
        subviews: Subviews
    ) -> (placements: [Placement], size: CGSize) {
        let maxWidth = proposedWidth ?? subviews.reduce(0) { width, subview in
            width + subview.sizeThatFits(.unspecified).width
        }
        var placements: [Placement] = []
        var line: [Placement] = []
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var y: CGFloat = 0
        var totalWidth: CGFloat = 0

        func flushLine(spacingAfter: CGFloat) {
            guard !line.isEmpty else { return }

            for placement in line {
                let centeredOrigin = CGPoint(
                    x: placement.origin.x,
                    y: y + (lineHeight - placement.size.height) / 2
                )
                placements.append(Placement(
                    index: placement.index,
                    origin: centeredOrigin,
                    size: placement.size
                ))
            }

            totalWidth = max(totalWidth, lineWidth)
            y += lineHeight + spacingAfter
            line.removeAll(keepingCapacity: true)
            lineWidth = 0
            lineHeight = 0
        }

        for index in subviews.indices {
            let subview = subviews[index]

            if subview[InlineCodeLineBreakKey.self] {
                if line.isEmpty {
                    y += subview.sizeThatFits(.unspecified).height
                } else {
                    flushLine(spacingAfter: 0)
                }
                continue
            }

            let size = subview.sizeThatFits(.unspecified)

            if !line.isEmpty, lineWidth + size.width > maxWidth {
                flushLine(spacingAfter: verticalSpacing)
            }

            let x = lineWidth
            line.append(Placement(
                index: index,
                origin: CGPoint(x: x, y: 0),
                size: size
            ))
            lineWidth = x + size.width
            lineHeight = max(lineHeight, size.height)
        }

        flushLine(spacingAfter: 0)

        return (placements, CGSize(width: totalWidth, height: max(y, 0)))
    }

    private struct Placement {
        let index: Int
        let origin: CGPoint
        let size: CGSize
    }
}

/// One labeled example: a code snippet, optionally followed by a live demo.
private struct LessonExample<Demo: View>: View {
    let label: String
    // `import Splash` also exports a `Color` typealias, so qualify SwiftUI's.
    let tint: SwiftUI.Color
    let systemImage: String
    let code: String
    let showsDemo: Bool
    @ViewBuilder let demo: Demo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(label, systemImage: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(tint)

            CodeBlock(code: code)

            if showsDemo {
                demo
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.background, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct CodeBlock: View {
    /// Swift code rendered with Splash syntax highlighting.
    ///
    /// Splash's bundled themes are tuned for dark editors, so the snippet
    /// keeps a dark background in both light and dark mode for legible,
    /// consistent coloring.
    private let highlighted: AttributedString

    init(code: String) {
        self.highlighted = Self.highlight(code)
    }

    var body: some View {
        Text(highlighted)
            // Let the text grow to its full height at the final width so it
            // never truncates. Without this, ImageRenderer measures each line
            // unwrapped, then truncates the last line when a long line wraps
            // at the fixed export width.
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(SwiftUI.Color(white: 0.12), in: RoundedRectangle(cornerRadius: 8))
            .textSelection(.enabled)
    }

    // Splash builds the highlighter once; reusing it avoids re-parsing the
    // theme for every snippet on screen. The Menlo font (baked in by the
    // theme) is carried through into the AttributedString.
    private static let highlighter = SyntaxHighlighter(
        format: AttributedStringOutputFormat(theme: theme)
    )

    private static func highlight(_ code: String) -> AttributedString {
        var highlighted = AttributedString(highlighter.highlight(code))
        // Splash bakes in a platform font (Menlo on iOS), but no monospaced
        // font resolves on macOS, where it falls back to the proportional
        // system font. Override it with a SwiftUI monospaced font so the
        // snippet renders identically on every platform.
        highlighted.font = .system(size: 15, design: .monospaced)
        return highlighted
    }

    /// Colors modeled on Xcode's "Midnight" dark theme — vibrant and
    /// readable, but a step down from Splash's neon bundled themes.
    private static let theme = Theme(
        font: Splash.Font(size: 15),
        plainTextColor: rgb(0xFFFFFF),
        tokenColors: [
            .keyword: rgb(0xFF7AB2),       // pink
            .string: rgb(0xFF8170),        // coral
            .type: rgb(0x9EF1DD),          // mint
            .call: rgb(0x67B7A4),          // teal
            .number: rgb(0xD9C97C),        // gold
            .comment: rgb(0x7F8C98),       // slate gray
            .property: rgb(0xACF2E4),      // pale mint
            .dotAccess: rgb(0x67B7A4),     // teal (match calls)
            .preprocessing: rgb(0xFFA14F)  // orange
        ],
        backgroundColor: rgb(0x292A30)
    )

    /// Builds a Splash color from a 0xRRGGBB hex value.
    private static func rgb(_ hex: UInt32) -> Splash.Color {
        Splash.Color(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

private extension SwiftUI.Color {
    /// Muted tints for the "Avoid"/"Prefer" cards — softer than the full
    /// system red/green so they sit calmly next to the code blocks.
    static let avoid = SwiftUI.Color(red: 0.80, green: 0.33, blue: 0.31)
    static let prefer = SwiftUI.Color(red: 0.31, green: 0.62, blue: 0.43)
}
