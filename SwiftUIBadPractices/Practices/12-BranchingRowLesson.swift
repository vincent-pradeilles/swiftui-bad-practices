import SwiftUI

struct BranchingRowLesson: View {
    static let title = "if/else in rows"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            A lazy container like `List` or `LazyVStack` can figure out each \
            row's identity up front, without evaluating every row's `body`.
            
            But this is only possible when the row is a single top-level view.

            A top-level `if`/`else` or `switch` hides the row's shape behind a branch, so \
            SwiftUI can't tell from the type alone what each row produces.
            
            It \
            must fall back to evaluating every row's `body`, and the cost scales with \
            the row count.

            Wrap branching content in a single-root container so the row \
            contains exactly one top-level view.
            """,
            avoidCode: """
            List(items) { item in
                if item.isHighlighted {
                    Label(item.title, systemImage: "star.fill")
                } else {
                    Text(item.title)
                }
            }
            """,
            preferCode: """
            List(items) { item in
                VStack {
                    if item.isHighlighted {
                        Label(item.title, systemImage: "star.fill")
                    } else {
                        Text(item.title)
                    }
                }
            }
            """
        )
    }
}
