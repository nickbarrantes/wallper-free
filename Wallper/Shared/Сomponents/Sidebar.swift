import SwiftUI

struct SidebarItem: View {
    var icon: String
    var text: String
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.primary.opacity(0.8))
                .frame(width: 16)

            Text(text)
                .foregroundColor(isSelected ? Color.primary.opacity(1) : Color.primary.opacity(0.45))
                .font(.system(size: 12, weight: .regular))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.primary.opacity(0.1) : Color.clear)
        )
        .animation(.easeInOut(duration: 0.25), value: isSelected)
        .contentShape(Rectangle())
    }
}

struct SidebarSettingsRow: View {
    let title: String
    @Binding var isOn: Bool
    var icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 16)

            Text(title)
                .foregroundColor(.primary)
                .font(.system(size: 13, weight: .regular))

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .scaleEffect(0.7)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.vertical, 8)
        .padding(.leading, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
        )
        .contentShape(Rectangle())
    }
}

struct SidebarButton: View {
    let item: NavigationItem
    let icon: String
    let text: String
    @Binding var selection: Set<NavigationItem>

    var isSelected: Bool {
        selection.contains(item)
    }

    var body: some View {
        Button(action: {
            withAnimation {
                selection = [item]
            }
        }) {
            SidebarItem(icon: icon, text: text, isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct Sidebar: View {
    @Binding var selection: Set<NavigationItem>
    @State private var glowPhase: Double = 0
    @EnvironmentObject var videoLibrary: VideoLibraryStore
    
    @State private var launchAtLogin = false
    @State private var randomVideo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Text("Wallper")
                                .font(.custom("TrebuchetMS", size: 18).weight(.semibold))
                                .overlay(
                                    LinearGradient(
                                        colors: [Color.primary.opacity(1.0), Color.primary.opacity(0.4)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text("Wallper")
                                            .font(.custom("TrebuchetMS", size: 18).weight(.semibold))
                                    )
                                )
                            ZStack(alignment: .topTrailing) {
                                Text("Free")
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.green.opacity(0.8))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )

                                Image(systemName: "heart.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                                    .offset(x: 2, y: -2)
                                    .shadow(color: .green.opacity(0.6), radius: 2)
                            }

                        }.padding(.horizontal, 8)

                        SidebarButton(item: .wallpers, icon: "sparkles", text: "Wallpapers", selection: $selection)
                            .padding(.top, 20)
                        
                        SidebarButton(item: .settings, icon: "gear", text: "Settings", selection: $selection)
                            .padding(.top, 16)
                    }
                }
                .padding(.top, 48)
                .padding(.horizontal, 24)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    _ = videoLibrary.selectLocalFolder()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text("Select Video Folder")
                            .foregroundColor(.primary)
                            .font(.system(size: 12, weight: .regular))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .padding(.bottom, 8)
            }
        }
        .frame(width: 235)
        .background(Color.clear)
    }
}
