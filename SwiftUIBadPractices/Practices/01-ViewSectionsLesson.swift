import SwiftUI

struct ViewSectionsLesson: View {
    static let title = "Splitting Large Views"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            Splitting a `body` into computed properties looks like efficient factoring, \
            but they all still share their `View`'s invalidation boundary. So every state \
            update will re-evaluate every section.
            
            Separate `View` structs each get \
            their own boundary. So only the section whose inputs actually \
            changed will be re-evaluated.
            """,
            avoidCode: """
            var body: some View {
                VStack { 
                    header
                    details
                }
            }
            
            private var header: some View { ... }
            private var details: some View { ... }
            """,
            preferCode: """
            var body: some View {
                VStack {
                    ProfileHeader(name: name)
                    ProfileDetails(isExpanded: isExpanded)
                }
            }
            """
        )
    }
}
