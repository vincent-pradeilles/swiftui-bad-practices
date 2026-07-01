import SwiftUI

struct InlineSortFilterLesson: View {
    static let title = "Inline Sort & Filter"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            The collection passed to ForEach is rebuilt every time the enclosing \
            body runs. Sorting or filtering inline repeats that work on every \
            invalidation, even unrelated ones. Cache the derived collection on an \
            @Observable model and recompute it only when its inputs change.
            """,
            avoidCode: """
            ForEach(tasks
                .filter { ... }
                .sorted()
            ) { task in Text(task) }   // re-runs on every body pass
            """,
            preferCode: """
            var tasks: [String] { didSet { recompute() } }
            var query: String { didSet { recompute() } }
            private(set) var visible: [String] = []

            ForEach(model.visible) { task in Text(task) }
            """
        )
    }
}
