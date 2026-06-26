import SwiftUI

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
                    tint: .red,
                    systemImage: "xmark.octagon.fill",
                    code: avoidCode,
                    showsDemo: showsDemos
                ) {
                    avoidDemo
                }

                LessonExample(
                    label: "Prefer",
                    tint: .green,
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
    let tint: Color
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
    let code: String

    var body: some View {
        Text(code)
            .font(.system(.body, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            .textSelection(.enabled)
    }
}
