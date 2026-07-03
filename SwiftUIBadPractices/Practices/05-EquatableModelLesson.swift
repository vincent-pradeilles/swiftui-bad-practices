import SwiftUI

struct EquatableModelLesson: View {
    static let title = "Equatable Models"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            The `@Observable` macro generates property setters that skip invalidation \
            when the new value equals the current one, but only if its type is \
            `Equatable`. 
            
            Without that conformance, every assignment notifies \
            its observers, even when the value is identical.
            
            Conforming the property \
            type to `Equatable` can help a lot for frequently-written values.
            """,
            avoidCode: """
            struct Coordinate {
                var latitude: Double
                var longitude: Double
            }

            @Observable @MainActor
            final class LocationModel {
                var coordinate = Coordinate(latitude: 0, longitude: 0)
            }

            // GPS updates ~1/s and each update notifies the view
            """,
            preferCode: """
            struct Coordinate: Equatable {
                var latitude: Double
                var longitude: Double
            }

            @Observable @MainActor
            final class LocationModel {
                var coordinate = Coordinate(latitude: 0, longitude: 0)
            }

            // skips identical updates, notifies only on real movement
            """
        )
    }
}
