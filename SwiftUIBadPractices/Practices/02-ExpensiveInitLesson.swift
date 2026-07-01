import SwiftUI

struct ExpensiveInitLesson: View {
    static let title = "View init"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            A view's init runs every time its parent's body runs, many times \
            per second inside lists and animations. Treat init as a cheap copy \
            of inputs: don't decode, format dates, or touch the file system there. \
            Pass prepared values and let SwiftUI format with Text(_:format:).
            """,
            avoidCode: """
            init(rawJSON: Data, date: Date) {
                summary = try! JSONDecoder()
                    .decode(WeatherSummary.self, from: rawJSON)
                let formatter = DateFormatter()    // allocated every pass
                formatter.dateStyle = .medium
                formattedDate = formatter.string(from: date)
            }
            """,
            preferCode: """
            let headline: String
            let date: Date

            Text(date, format: .dateTime.day().month().year())
            """
        )
    }
}
