import SwiftUI

struct ViewSectionsLesson: View {
    var body: some View {
        LessonPage(
            title: "View Sections",
            explanation: """
            Splitting a body into computed properties looks like factoring, \
            but they all share the parent's invalidation boundary — one state \
            change re-evaluates every section. Separate View structs each get \
            their own boundary, so only the section whose inputs changed re-runs.
            """,
            avoidCode: """
            var body: some View {
                VStack { header; details }
            }
            private var header: some View { ... }  // re-runs on every toggle
            private var details: some View { ... }
            """,
            preferCode: """
            var body: some View {
                VStack {
                    ProfileHeader(name: name)            // own boundary
                    ProfileDetails(isExpanded: isExpanded)
                }
            }
            """
        )
    }
}
