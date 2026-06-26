import SwiftUI

@main
struct SwiftUIBadPracticesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Top-level menu. Each row opens one lesson, and each lesson lives in
/// its own file demonstrating a single SwiftUI bad practice alongside
/// the recommended alternative.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("View Structure") {
                    NavigationLink("Sections as computed properties") { ViewSectionsLesson() }
                    NavigationLink("Expensive work in init") { ExpensiveInitLesson() }
                    NavigationLink("Single-child Group") { SingleChildGroupLesson() }
                }

                Section("Data Flow") {
                    NavigationLink("Passing whole structs") { NarrowInputsLesson() }
                    NavigationLink("Non-Equatable model properties") { EquatableModelLesson() }
                    NavigationLink("Closure bindings") { ClosureBindingLesson() }
                }

                Section("Environment") {
                    NavigationLink("Closures in the environment") { ClosureEnvironmentLesson() }
                    NavigationLink("Unstable environment defaults") { UnstableDefaultLesson() }
                }

                Section("Modifiers") {
                    NavigationLink("Conditional view modifiers") { ConditionalModifierLesson() }
                }

                Section("ForEach & List") {
                    NavigationLink("Indices as identity") { IndicesIdentityLesson() }
                    NavigationLink("Inline sort & filter") { InlineSortFilterLesson() }
                    NavigationLink("AnyView rows") { AnyViewRowLesson() }
                }
            }
            .navigationTitle("Bad Practices")
        }
        // Scale all semantic-font text up for legible video recording on
        // a large iPad in landscape.
        .dynamicTypeSize(.xxLarge)
    }
}

#Preview {
    ContentView()
}
