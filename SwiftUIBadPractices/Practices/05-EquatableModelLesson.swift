import SwiftUI

struct EquatableModelLesson: View {
    static let title = "Equatable Models"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            The `@Observable` macro generates a setter that skips invalidation \
            when the new value equals the current one, but only if the type is \
            `Equatable`. Without that conformance, every assignment notifies \
            observers, even when the value is identical. Conforming the property \
            type to `Equatable` is a free win for frequently-written values.
            """,
            avoidCode: """
            enum DeliveryStatus { case placed, shipped }

            @MainActor @Observable
            final class Order { var status: DeliveryStatus = .placed }
            // setting .shipped twice invalidates twice
            """,
            preferCode: """
            enum DeliveryStatus: Equatable { case placed, shipped }

            @MainActor @Observable
            final class Order { var status: DeliveryStatus = .placed }
            // setting .shipped twice invalidates once
            """
        )
    }
}
