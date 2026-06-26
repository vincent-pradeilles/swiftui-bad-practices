import SwiftUI
import Splash

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
            VStack(alignment: .leading, spacing: 24) {
                Text(explanation)
                    .font(.title3)

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
            // Match the navigation bar's large-title leading inset (20pt on
            // iPad) so the body and cards align with the title.
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle(title)
    }
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
        AttributedString(highlighter.highlight(code))
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
