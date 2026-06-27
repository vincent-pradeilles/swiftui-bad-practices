import SwiftUI

@main
struct SwiftUIBadPracticesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// One lesson in the catalog. The case identity drives the sidebar
/// selection and selects which detail view to show; each lesson lives in
/// its own file demonstrating a single SwiftUI bad practice alongside the
/// recommended alternative.
enum Lesson: Identifiable, Hashable, CaseIterable {
    case viewSections, expensiveInit, singleChildGroup
    case narrowInputs, equatableModel, closureBinding
    case closureEnvironment, unstableDefault
    case conditionalModifier
    case indicesIdentity, inlineSortFilter, anyViewRow

    var id: Self { self }

    var title: String {
        switch self {
        case .viewSections: "Sections as computed properties"
        case .expensiveInit: "Expensive work in init"
        case .singleChildGroup: "Single-child Group"
        case .narrowInputs: "Passing whole structs"
        case .equatableModel: "Non-Equatable model properties"
        case .closureBinding: "Closure bindings"
        case .closureEnvironment: "Closures in the environment"
        case .unstableDefault: "Unstable environment defaults"
        case .conditionalModifier: "Conditional view modifiers"
        case .indicesIdentity: "Indices as identity"
        case .inlineSortFilter: "Inline sort & filter"
        case .anyViewRow: "AnyView rows"
        }
    }

    @ViewBuilder var detail: some View {
        switch self {
        case .viewSections: ViewSectionsLesson()
        case .expensiveInit: ExpensiveInitLesson()
        case .singleChildGroup: SingleChildGroupLesson()
        case .narrowInputs: NarrowInputsLesson()
        case .equatableModel: EquatableModelLesson()
        case .closureBinding: ClosureBindingLesson()
        case .closureEnvironment: ClosureEnvironmentLesson()
        case .unstableDefault: UnstableDefaultLesson()
        case .conditionalModifier: ConditionalModifierLesson()
        case .indicesIdentity: IndicesIdentityLesson()
        case .inlineSortFilter: InlineSortFilterLesson()
        case .anyViewRow: AnyViewRowLesson()
        }
    }
}

/// A titled group of lessons, used to build the sidebar's sections.
struct LessonSection: Identifiable {
    let title: String
    let lessons: [Lesson]

    var id: String { title }

    static let all: [LessonSection] = [
        LessonSection(title: "View Structure", lessons: [.viewSections, .expensiveInit, .singleChildGroup]),
        LessonSection(title: "Data Flow", lessons: [.narrowInputs, .equatableModel, .closureBinding]),
        LessonSection(title: "Environment", lessons: [.closureEnvironment, .unstableDefault]),
        LessonSection(title: "Modifiers", lessons: [.conditionalModifier]),
        LessonSection(title: "ForEach & List", lessons: [.indicesIdentity, .inlineSortFilter, .anyViewRow])
    ]
}

/// Top-level layout: a sidebar listing every lesson, with the selected
/// lesson shown in the detail pane — the idiomatic split-view layout for a
/// Mac app.
struct ContentView: View {
    @State private var selection: Lesson? = .viewSections

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(LessonSection.all) { section in
                    Section(section.title) {
                        ForEach(section.lessons) { lesson in
                            Text(lesson.title).tag(lesson)
                        }
                    }
                }
            }
            .navigationTitle("Bad Practices")
        } detail: {
            if let selection {
                NavigationStack {
                    selection.detail
                }
            } else {
                ContentUnavailableView(
                    "Select a Lesson",
                    systemImage: "sidebar.left",
                    description: Text("Choose a bad practice from the sidebar.")
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
