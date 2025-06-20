import SwiftUI

@main
struct WallperApp: App {

    init() {
        Env.shared.loadSyncFromLambda()
    }
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .centerWindow()
                .useCustomWindow()
                .frame(minWidth: 1300, minHeight: 768)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
    }
}
