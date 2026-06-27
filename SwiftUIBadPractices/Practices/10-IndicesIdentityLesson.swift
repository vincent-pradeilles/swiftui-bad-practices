import SwiftUI

/// A row that owns per-row @State (a "starred" flag). If identity is
/// wrong, the star stays at a position instead of following its element.
private struct FruitRow: View {
    let name: String
    @State private var starred = false

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Image(systemName: starred ? "star.fill" : "star")
                .foregroundStyle(.yellow)
        }
        .contentShape(.rect)
        .onTapGesture { starred.toggle() }
    }
}

// MARK: - Avoid: indices as identity

/// `id: \.self` on indices ties identity to position. Star a row, then
/// insert at the top: index 0's @State stays put, so the star "jumps" to
/// the newly inserted row.
private struct BadIdentityList: View {
    @State private var fruits = ["Apple", "Banana", "Cherry"]

    var body: some View {
        VStack(alignment: .leading) {
            Button("Insert at top") { fruits.insert("New \(fruits.count)", at: 0) }
            ForEach(fruits.indices, id: \.self) { index in
                FruitRow(name: fruits[index])
            }
        }
    }
}

// MARK: - Prefer: identity from the element itself

private struct GoodIdentityList: View {
    @State private var fruits = ["Apple", "Banana", "Cherry"]

    var body: some View {
        VStack(alignment: .leading) {
            Button("Insert at top") { fruits.insert("New \(fruits.count)", at: 0) }
            ForEach(fruits, id: \.self) { name in
                FruitRow(name: name)
            }
        }
    }
}

// MARK: - Lesson

struct IndicesIdentityLesson: View {
    var body: some View {
        LessonPage(
            title: "Indices as Identity",
            explanation: """
            ForEach uses identity to match rows across updates. An index \
            describes a position, not an element. Insert or reorder and the same \
            index points to a different element, so row @State, focus, and \
            animations break. Star a row below, then insert at the top: with \
            indices the star jumps; with element identity it follows its row.
            """,
            avoidCode: """
            ForEach(fruits.indices, id: \\.self) { index in
                FruitRow(name: fruits[index])
            }
            """,
            preferCode: """
            ForEach(fruits, id: \\.self) { name in
                FruitRow(name: name)
            }
            """
        ) {
            BadIdentityList()
        } preferDemo: {
            GoodIdentityList()
        }
    }
}
