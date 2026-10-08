import SwiftUI

@main struct MyApp: App {
    @State private var store = BrainStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
            #if os(macOS)
                .frame(minWidth: 1180, minHeight: 760)
            #endif
        }
        #if os(macOS)
        .defaultSize(width: 1400, height: 880)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
