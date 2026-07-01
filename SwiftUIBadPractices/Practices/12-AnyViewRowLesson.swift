import SwiftUI

struct AnyViewRowLesson: View {
    static let title = "AnyView Rows"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            AnyView erases a view's type, and with it the structural identity List \
            relies on to template row ids from the type alone. The List then has \
            to evaluate every row's body to diff, and the cost scales with the row \
            count. Use a concrete row view with the switch inside a single-root \
            container instead.
            """,
            avoidCode: """
            func row(for item: Item) -> AnyView {
                switch item {
                case .plain(let t):       AnyView(Text(t))
                case .highlighted(let t): AnyView(Text(t).bold())
                }
            }
            List(items) { row(for: $0) }
            """,
            preferCode: """
            struct ItemRow: View {
                let item: Item
                var body: some View {
                    VStack {
                        switch item { ... }   // one top-level view
                    }
                }
            }
            List(items) { ItemRow(item: $0) }
            """
        )
    }
}
