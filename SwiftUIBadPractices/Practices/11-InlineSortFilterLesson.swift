import SwiftUI

struct InlineSortFilterLesson: View {
    static let title = "Expensive Inline Work in ForEach"

    var body: some View {
        LessonPage(
            title: Self.title,
            explanation: """
            The `Collection` passed to `ForEach` is rebuilt every time the enclosing \
            `body` runs. 
            
            Sorting or filtering inline repeats that work on every \
            invalidation, even when the `Collection` hasn't changed.
            
            Caching the derived `Collection` in an \
            `@Observable` model lets you perform that work \
            only when it is actually necessary.
            """,
            avoidCode: """
            ForEach(contacts
                .filter { $0.name.contains(query) }
                .sorted { $0.name < $1.name }
            ) { contact in ContactRow(contact) }
            """,
            preferCode: """
            @Observable @MainActor
            final class ContactsModel {
                var contacts: [Contact] = [] { didSet { search() } }
                var query: String = "" { didSet { search() } }

                // recomputed only when contacts or query change
                private(set) var results: [Contact] = []

                private func search() {
                    results = contacts
                        .filter { $0.name.contains(query) }
                        .sorted { $0.name < $1.name }
                }
            }

            ForEach(model.results) { contact in ContactRow(contact) }
            """
        )
    }
}
