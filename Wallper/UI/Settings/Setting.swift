import SwiftUI
import AVFoundation
import ServiceManagement

struct SettingsView: View {
    @AppStorage("restoreLastWallpapers") private var restoreLastWallpapers: Bool = false
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @EnvironmentObject var videoLibrary: VideoLibraryStore

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(alignment: .center, spacing: 0) {
                headerSection
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 32)

                VStack(spacing: 16) {
                    toggleRow(
                        title: "Restore wallpapers on launch",
                        description: "Automatically reapplies the last wallpapers when Wallper starts.",
                        isOn: $restoreLastWallpapers
                    )
                    
                    toggleRow(
                        title: "Launch at login",
                        description: "Automatically start Wallper when you log into macOS.",
                        isOn: $launchAtLogin
                    )
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
                    
                    currentFolderSection
                }
                .frame(width: 480)
                .padding(.top, 16)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color("#101010"))
    }

    var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "gear")
                .font(.system(size: 40))
                .foregroundColor(.white)

            Text("Settings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    func toggleRow(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.primary.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
        .cornerRadius(12)
    }
    
    var currentFolderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Video Folder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                    if let folderPath = videoLibrary.localFolderPath {
                        Text(folderPath)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    } else {
                        Text("No folder selected")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()
                
                Button("Change Folder") {
                    _ = videoLibrary.selectLocalFolder()
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .cornerRadius(6)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.primary.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
        .cornerRadius(12)
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
        }
    }
}