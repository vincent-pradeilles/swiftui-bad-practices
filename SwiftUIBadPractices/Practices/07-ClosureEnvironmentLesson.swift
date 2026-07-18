import SwiftUI

struct ClosureEnvironmentLesson: View {
    static let title = "Closures in the Environment"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            Never store closures directly in an `Environment` key.

            SwiftUI can't compare closures, so every child `View` that \
            reads the `Environment` key will be invalidated each time \
            that the `Environment` is updated.

            Instead, create a dedicated type and implement the behavior through \
            the special method `callAsFunction()`, which lets you call values \
            of that type with the same syntax than a closure.
            """,
            avoidCode: """
            extension EnvironmentValues {
                @Entry var submit: (String) -> Void = { _ in }
            }

            @Environment(\\.submit) private var submit

            Button("Send") { submit(draft) }
            """,
            preferCode: """
            struct SubmitAction {
                func callAsFunction(_ draft: String) { ... }
            }

            extension EnvironmentValues {
                @Entry var submit = SubmitAction()
            }

            @Environment(\\.submit) private var submit

            Button("Send") { submit(draft) }
            """
        )
    }
}
