import SwiftUI

struct ContentView: View {
    let store: BrainStore
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ZStack {
            BackgroundView()
            if sizeClass == .compact { compact } else { wide }
        }
        .preferredColorScheme(.dark)
    }

    private var wide: some View {
        HStack(alignment: .top, spacing: 14) {
            LibraryPanel(store: store).frame(width: 250)
            VStack(spacing: 12) {
                HeaderBar(store: store)
                BrainView(store: store).frame(maxWidth: .infinity, maxHeight: .infinity)
                ActiveBanner(store: store)
                TimelinePanel(store: store)
            }
            StatusPanel(store: store).frame(width: 300)
        }
        .padding(16)
    }

    private var compact: some View {
        TabView {
            VStack(spacing: 10) {
                HeaderBar(store: store)
                BrainView(store: store).frame(maxWidth: .infinity, maxHeight: .infinity)
                ActiveBanner(store: store)
                TimelinePanel(store: store)
            }
            .padding(12)
            .tabItem { Label("Beyin", systemImage: "brain.head.profile") }

            LibraryPanel(store: store).padding(12)
                .tabItem { Label("Görevler", systemImage: "list.bullet") }

            StatusPanel(store: store).padding(12)
                .tabItem { Label("Durum", systemImage: "chart.bar.fill") }
        }
    }
}

#Preview {
    ContentView(store: BrainStore())
}
