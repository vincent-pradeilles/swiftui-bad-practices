import SwiftUI

struct NarrowInputsLesson: View {
    var body: some View {
        LessonPage(
            title: "Narrow Inputs",
            explanation: """
            For value-type inputs, a view's input shape is its invalidation \
            surface. A view declared with `let account: Account` re-runs when \
            any field of the struct changes, even fields it never reads. Pass \
            each view only the fields it actually renders.
            """,
            avoidCode: """
            struct NameTag: View {
                let account: Account     // re-runs on any Account change
                var body: some View { Text(account.name) }
            }
            """,
            preferCode: """
            struct NameTag: View {
                let name: String         // re-runs only when name changes
                var body: some View { Text(name) }
            }
            """
        )
    }
}
