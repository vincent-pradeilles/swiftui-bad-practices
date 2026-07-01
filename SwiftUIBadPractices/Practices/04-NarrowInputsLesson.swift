import SwiftUI

struct NarrowInputsLesson: View {
    static let title = "Narrow View Inputs"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            For value-type inputs, a view's parameter list is its invalidation \
            surface. 
            
            A view declared with `let account: Account` will re-run when \
            any field of that struct changes, even fields it never reads.
            
            Pass each view only the fields it actually renders.
            """,
            avoidCode: """
            struct NameTag: View {
                let account: Account
                var body: some View { Text(account.name) }
            }
            """,
            preferCode: """
            struct NameTag: View {
                let name: String
                var body: some View { Text(name) }
            }
            """
        )
    }
}
