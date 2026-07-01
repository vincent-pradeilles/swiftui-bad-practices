import SwiftUI

// MARK: - The anti-pattern: a conditional `.if` modifier

/// Branching between `transform(self)` and `self` produces two different
/// view types. Toggling the condition swaps one for the other, destroying
/// structural identity, so descendant @State is reset.
private extension View {
    @ViewBuilder
    func `if`<Transformed: View>(
        _ condition: Bool,
        transform: (Self) -> Transformed
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// A field with its own @State. We can watch whether typed text survives.
private struct DraftField: View {
    @State private var text = ""

    var body: some View {
        TextField("Type something, then toggle…", text: $text)
            .textFieldStyle(.roundedBorder)
    }
}

// MARK: - Avoid

private struct BadConditional: View {
    @State private var highlighted = false

    var body: some View {
        VStack(spacing: 12) {
            DraftField()
                .if(highlighted) { $0.padding().background(.yellow.opacity(0.3)) }
            Toggle("Highlight (resets the field!)", isOn: $highlighted)
        }
    }
}

// MARK: - Prefer

private struct GoodConditional: View {
    @State private var highlighted = false

    var body: some View {
        VStack(spacing: 12) {
            DraftField()
                .padding()
                .background(highlighted ? Color.yellow.opacity(0.3) : .clear)
            Toggle("Highlight (text is preserved)", isOn: $highlighted)
        }
    }
}

// MARK: - Lesson

struct ConditionalModifierLesson: View {
    static let title = "Conditional Modifiers"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            A conditional `.if` modifier switches between two view types, so \
            toggling the condition breaks structural identity: descendant `@State` \
            resets and animations become abrupt replacements. Type into each \
            field below, then flip the toggle, and the Avoid field loses its text. \
            Apply the value conditionally with a ternary instead.
            """,
            avoidCode: """
            Text("Hello")
                .if(isHighlighted) { $0.foregroundStyle(.red) }
            // identity (and @State) is lost when isHighlighted flips
            """,
            preferCode: """
            Text("Hello")
                .foregroundStyle(isHighlighted ? .red : .primary)
            // same view, identity preserved, animates smoothly
            """
        ) {
            BadConditional()
        } preferDemo: {
            GoodConditional()
        }
    }
}
