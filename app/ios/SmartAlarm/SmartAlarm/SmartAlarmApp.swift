import SwiftUI

@main
struct SmartAlarmApp: App {
    @State private var store = MockAlarmStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .preferredColorScheme(.dark)
        }
    }
}
