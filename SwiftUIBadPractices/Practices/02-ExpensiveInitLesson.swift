import SwiftUI

struct ExpensiveInitLesson: View {
    static let title = "View init"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            A view's `init` runs every time its parent re-evaluates `body`, which can \
            be many times per second in lists, scroll containers, or animated parents. \
            Treat `init` as a cheap copy of inputs: don't decode, allocate formatters, \
            build formatted strings, or touch the file system there. Pass prepared \
            values and let SwiftUI format dates at display time with `Text(_:format:)`.
            """,
            avoidCode: """
            struct WeatherCard: View {
                let summary: WeatherSummary
                let formattedDate: String

                init(rawJSON: Data, date: Date) {
                    self.summary = try! JSONDecoder()
                        .decode(WeatherSummary.self, from: rawJSON)
                    let formatter = DateFormatter()    // allocated every pass
                    formatter.dateStyle = .medium
                    self.formattedDate = formatter.string(from: date)
                }

                var body: some View {
                    VStack {
                        Text(summary.headline)
                        Text(formattedDate)
                    }
                }
            }
            """,
            preferCode: """
            struct WeatherCard: View {
                let headline: String
                let date: Date

                var body: some View {
                    VStack {
                        Text(headline)
                        Text(date, format: .dateTime.day().month().year())
                    }
                }
            }
            """
        )
    }
}
