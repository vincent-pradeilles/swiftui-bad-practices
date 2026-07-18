import SwiftUI

struct ClosureBindingLesson: View {
    static let title = "Closure Bindings"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            Building a `Binding` from get/set closures allocates a new pair of \
            closures every time the `body` is evaluated.

            SwiftUI can't compare closures, so it can't tell whether the binding is \
            still the same one as last time. It re-runs the child view even \
            when nothing actually changed.

            Add a subscript to the model and let `@Bindable` derive the binding \
            through it. That binding is a stable key path SwiftUI can compare, \
            so it skips the wasted work.
            """,
            avoidCode: """
            let binding = Binding(
                get: { model[scoreFor: player] },
                set: { model[scoreFor: player] = $0 }
            )
            ScoreRow(player: player, score: binding)
            """,
            preferCode: """
            @Bindable var model = model
            ScoreRow(player: player, score: $model[scoreFor: player])
            """
        )
    }
}
