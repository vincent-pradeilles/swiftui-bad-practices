import SwiftUI

struct SingleChildGroupLesson: View {
    static let title = "Single-child Group"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            A `Group` with exactly one concrete child has no visual effect but \
            wraps the view in an extra `Group<Child>` type. 
            
            Every modifier you \
            chain afterwards is type-checked against that wrapper, adding \
            needless compile-time overhead. 
            
            Drop the `Group` and chain directly.
            
            (However, a `Group` around an `if`/`else` or a `ForEach` is doing real work and is fine.)
            """,
            avoidCode: """
            Group {
                Text(status)
            }
            .padding(.horizontal, 10)
            .background(.thinMaterial, in: Capsule())
            """,
            preferCode: """
            Text(status)
                .padding(.horizontal, 10)
                .background(.thinMaterial, in: Capsule())
            """
        )
    }
}
