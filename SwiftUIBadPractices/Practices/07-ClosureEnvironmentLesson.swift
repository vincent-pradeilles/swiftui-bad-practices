import SwiftUI

struct ClosureEnvironmentLesson: View {
    var body: some View {
        LessonPage(
            title: "Closures in Environment",
            explanation: """
            Never store closures in your own environment keys. SwiftUI can't \
            compare function values, so every reader in the subtree invalidates \
            on every environment update. Eliminate the closure: hold the data it \
            would capture as stored properties and expose behavior via a method \
            or callAsFunction. (Framework keys like \\.openURL or \\.dismiss are \
            designed for this and are fine.)
            """,
            avoidCode: """
            extension EnvironmentValues {
                @Entry var submit: (String) -> Void = { _ in }
            }
            // every reader invalidates on every env update
            """,
            preferCode: """
            struct SubmitAction {
                func callAsFunction(_ draft: String) { ... }
            }
            extension EnvironmentValues {
                @Entry var submit = SubmitAction()
            }
            """
        )
    }
}
