import SwiftUI

struct ClosureBindingLesson: View {
    static let title = "Building a Binding using closures"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            Building a `Binding` from get/set closures will create a new pair of \
            closures every time the `body` is evaluated.

            SwiftUI can't compare the content of closures, so it can't tell whether the binding is \
            still the same one or has changed.

            So it will be forced re-evaluate the child view, even \
            when nothing has actually changed.

            Add a subscript to the model and let `@Bindable` derive the binding \
            through it.

            That binding is now a stable key path that SwiftUI can compare.
            """,
            avoidCode: """
            let binding = Binding(
                get: { model.scores[player.id, default: 0] },
                set: { model.scores[player.id] = $0 }
            )

            ScoreRow(player: player, score: binding)
            """,
            preferCode: """
            @Observable
            class Model {
                var scores: [Player.ID: Int] = [:]

                subscript(scoreFor player: Player) -> Int {
                    get { scores[player.id, default: 0] }
                    set { scores[player.id] = newValue }
                }
            }

            @Bindable var model = model
            ScoreRow(player: player, score: $model[scoreFor: player])
            """
        )
    }
}
