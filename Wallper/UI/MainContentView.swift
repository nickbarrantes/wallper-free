import SwiftUI
import AVFoundation

enum NavigationItem: Hashable {
    case wallpers, settings
}

extension Color {
    init(_ hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct MainContentView: View {
    @State private var selection: Set<NavigationItem> = [.wallpers]
    @State private var fullscreenVideo: VideoData? = nil
    @State private var wallperID = UUID()
    @State private var contentID = UUID()
    @State private var lastSelectedItem: NavigationItem?

    @StateObject private var videoLibrary = VideoLibraryStore()
    @StateObject private var filterStore = VideoFilterStore()
    
    @State private var screenChangeTrigger = UUID()
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Sidebar(selection: $selection)
                    .frame(width: 225)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: [.vertical])
                    .environmentObject(videoLibrary)
                    .overlay(
                        VStack { Spacer(minLength: 0) }
                            .frame(maxHeight: .infinity)
                            .frame(width: 1)
                            .background(Color.white.opacity(0.08)),
                        alignment: .trailing
                    )

                ContentDisplayView(
                    item: selection.first ?? .wallpers,
                    fullscreenVideo: $fullscreenVideo,
                    wallperID: $wallperID
                )
                .id(contentID)
                .background(.ultraThinMaterial)
                .environmentObject(videoLibrary)
                .environmentObject(filterStore)
            }

            if let item = fullscreenVideo {
                FullscreenVideoView(item: item, fullscreenVideo: $fullscreenVideo)
                    .environmentObject(videoLibrary)
            }
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 && fullscreenVideo != nil {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        fullscreenVideo = nil
                    }
                    return nil
                }
                return event
            }

            Task {
                await videoLibrary.loadAll()
                videoLibrary.loadCachedVideos()
                await filterStore.fetchDynamicFilters()
            }


            if UserDefaults.standard.bool(forKey: "restoreLastWallpapers") {
                applyLastUsedWallpapers()
            }
            

        }
        
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)) { _ in
            screenChangeTrigger = UUID()
        }
        .onChange(of: screenChangeTrigger) { _ in
            applyLastUsedWallpapers()
        }
        
    }

    private func applyLastUsedWallpapers() {
        let key = "LastAppliedWallpapers"
        guard let saved = UserDefaults.standard.array(forKey: key) as? [[String: Any]] else { return }

        for item in saved {
            if let index = item["screenIndex"] as? Int,
               let urlString = item["url"] as? String,
               let url = URL(string: urlString) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    VideoWallpaperManager.shared.setVideoAsWallpaper(from: url, screenIndex: index, applyToAll: false)
                }
            }
        }
    }
}

struct ContentDisplayView: View {
    var item: NavigationItem
    @Binding var fullscreenVideo: VideoData?
    @Binding var wallperID: UUID

    @EnvironmentObject var videoLibrary: VideoLibraryStore

    @State private var printedItems: Set<NavigationItem> = []

    var body: some View {
        ZStack {
            if !videoLibrary.isLoaded {
                loadingState("Loading videos...")
            } else {
                viewForItem(item)
                    .onAppear {
                        if !printedItems.contains(item) {
                            printedItems.insert(item)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func viewForItem(_ item: NavigationItem) -> some View {
        switch item {
        case .wallpers:
            WallperView(fullscreenVideo: $fullscreenVideo, videos: videoLibrary.wallpapersVideos)
                .id(wallperID)
        case .settings:
            SettingsView()
                .environmentObject(videoLibrary)
        }
    }

    @ViewBuilder
    private func loadingState(_ text: String) -> some View {
        VStack(spacing: 12) {
            MiniSpinner()
            Text(text)
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .transition(.opacity)
    }

    private func itemTitle(_ item: NavigationItem) -> String {
        switch item {
        case .wallpers: return "Wallpapers"
        case .settings: return "Settings"
        }
    }
}


