import SwiftUI

struct ClosureBindingLesson: View {
    static let title = "Closure Bindings"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            A get/set closure Binding is a fresh heap allocation on every body \
            evaluation and can't be compared reliably, causing spurious \
            invalidations. Project into the model through a subscript and derive \
            the Binding with @Bindable instead.
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
