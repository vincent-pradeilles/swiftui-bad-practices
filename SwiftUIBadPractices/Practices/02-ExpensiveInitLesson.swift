import SwiftUI

struct ExpensiveInitLesson: View {
    static let title = "View init"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            A view's `init` runs every time its parent re-evaluates `body`, which can \
            be many times per second in lists, scroll containers, or animated parents. \
            Treat `init` as a cheap copy of inputs. If an expensive helper really must \
            be allocated, move that ownership to stable state, then let the view render \
            the prepared value.
            """,
            avoidCode: """
            struct ArticlePreview: View {
                let preview: AttributedString

                init(markdown: String) {
                    let renderer = MarkdownRenderer()   // allocated every pass
                    self.preview = renderer.render(markdown)
                }

                var body: some View {
                    Text(preview)
                }
            }
            """,
            preferCode: """
            struct ArticlePreview: View {
                let markdown: String
                @State private var renderer = MarkdownRenderer()
                @State private var preview = AttributedString()

                var body: some View {
                    Text(preview)
                        .task(id: markdown) {
                            preview = renderer.render(markdown)
                        }
                }
            }
            """
        )
    }
}
