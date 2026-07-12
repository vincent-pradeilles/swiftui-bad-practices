import SwiftUI

struct UnstableDefaultLesson: View {
    static let title = "Reference Types and Environement Defaults"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            `@Entry` wraps its default value in a computed getter, so `@Entry var theme = \
            Theme()` will allocate a new instance on every fallback read.

            Any environment update makes readers re-read their keys and classes are compared by reference identity: this means that the previous default instance will always be invalidated.

            Replace the inline default value with \
            a stable default instance.
            
            (Or better, just use an `Optional` type when a default value isn't required.)
            """,
            avoidCode: """
            extension EnvironmentValues {
                @Entry var theme = Theme()
            }
            """,
            preferCode: """
            private let defaultTheme = Theme()
            
            extension EnvironmentValues {
                @Entry var theme = defaultTheme
            }
            """
        )
    }
}
