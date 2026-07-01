import SwiftUI

struct UnstableDefaultLesson: View {
    static let title = "Unstable Defaults"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            `@Entry` wraps its default in a computed getter, so `@Entry var theme = \
            Theme()` allocates a new instance on every fallback read. Any \
            environment write makes readers re-read their keys, and the fresh \
            instance reads as "changed", invalidating them. Back the default with \
            a stable shared instance (or use an `Optional` `nil` default).
            """,
            avoidCode: """
            extension EnvironmentValues {
                @Entry var theme = Theme()   // new instance every read
            }
            """,
            preferCode: """
            private let sharedTheme = Theme()
            extension EnvironmentValues {
                @Entry var theme = sharedTheme   // stable
            }
            """
        )
    }
}
