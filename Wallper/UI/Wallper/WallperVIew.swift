import SwiftUI
import AVKit
import AppKit

struct WallperView: View {
    @EnvironmentObject var filterStore: VideoFilterStore
    @EnvironmentObject var videoLibrary: VideoLibraryStore

    @State private var showUI = false

    @Binding var fullscreenVideo: VideoData?
    var videos: [VideoData]

    @StateObject private var pagination = PaginationController<VideoData>(itemsPerPage: 21)

    enum SortOption: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case mostLiked = "Most Liked"
    }

    @State private var selectedSort: SortOption = .newest
    @State private var gridID = UUID()

    var body: some View {
        Group {
            if videoLibrary.localFolderPath != nil && !videos.isEmpty {
                contentView
                    .opacity(showUI ? 1 : 0)
                    .blur(radius: showUI ? 0 : 10)
                    .animation(.easeOut(duration: 0.6), value: showUI)
            } else {
                emptyStateView
            }
        }
        .onAppear {
            showUI = true
            applySortingAndFiltering()
            filterStore.resetFilters()
        }
        .onChange(of: selectedSort) { _ in
            applySortingAndFiltering()
        }
        .onChange(of: filterStore.selectedFilters) { _ in
            applySortingAndFiltering()
        }
        .onChange(of: filterStore.searchText) { _ in
            applySortingAndFiltering()
        }
        .onChange(of: videos) { _ in
            applySortingAndFiltering()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Video Folder Selected")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Click 'Select Video Folder' in the sidebar to choose a folder containing your video files.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                _ = videoLibrary.selectLocalFolder()
            }) {
                HStack {
                    Image(systemName: "folder")
                    Text("Select Video Folder")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(#colorLiteral(red: 0.06274510175, green: 0.06274510175, blue: 0.06274510175, alpha: 1)))
    }

    private func applySortingAndFiltering() {
        let filtered = filterStore.applyFilters(to: videos)
        let sorted = sortVideos(filtered, by: selectedSort)
        pagination.items = sorted
        pagination.goToPage(0)
        gridID = UUID()
    }

    private func sortVideos(_ videos: [VideoData], by option: SortOption) -> [VideoData] {
        switch option {
        case .newest:
            return videos.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        case .oldest:
            return videos.sorted { ($0.createdAt ?? "") < ($1.createdAt ?? "") }
        case .mostLiked:
            return videos.sorted { $0.likes > $1.likes }
        }
    }

    private var contentView: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 2
            let totalWidth = geometry.size.width - 32
            let minColumns = 3
            let idealColumnWidth = totalWidth / CGFloat(minColumns) - spacing
            let columns = [GridItem(.adaptive(minimum: idealColumnWidth), spacing: spacing)]

            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
                        ForEach(Array(pagination.pagedItems.enumerated()), id: \.1.id) { index, item in
                            WallperCard(item: item, index: index) {
                                fullscreenVideo = item
                            }
                        }
                    }
                    .id(gridID)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.easeInOut(duration: 0.3), value: pagination.currentPage)
                    .padding(.bottom, 112)
                }
                .background(Color("#101010"))
                .padding(.top, 18)

                VStack(spacing: 0) {
                    HStack {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color.white.opacity(0.8))
                                .font(.system(size: 12, weight: .semibold))

                            Text("Local Videos")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))

                            Text("FREE • \(videos.count) videos")
                                .foregroundColor(.white.opacity(0.45))
                                .font(.system(size: 10, weight: .regular))
                                .baselineOffset(1)
                        }
                        .padding(.leading, 12)
                        .padding(.vertical, 8)
                        .frame(height: 46)

                        Spacer()

                        if pagination.totalPages >= 1 {
                            HStack(spacing: 12) {
                                Text("\(pagination.pagedItems.count + pagination.currentPage * pagination.itemsPerPage) of \(pagination.items.count) videos")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                                    .font(.system(size: 10, weight: .regular))

                                Button(action: {
                                    pagination.goToPage(pagination.currentPage - 1)
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10))
                                }
                                .background(Color("#131313"))
                                .clipShape(Circle())
                                .padding(.vertical, 5)
                                .disabled(pagination.currentPage == 0)

                                ForEach(pagination.visiblePageRange, id: \.self) { page in
                                    if page == -1 {
                                        Text("…")
                                            .foregroundColor(.white)
                                            .font(.system(size: 10))
                                    } else {
                                        Button(action: {
                                            pagination.goToPage(page)
                                        }) {
                                            Text("\(page + 1)")
                                                .font(.system(size: 10, weight: .regular))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(pagination.currentPage == page ? Color.blue : Color.clear)
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }

                                Button(action: {
                                    pagination.goToPage(pagination.currentPage + 1)
                                }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white)
                                        .font(.system(size: 10))
                                }
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .padding(.vertical, 5)
                                .disabled(pagination.currentPage >= pagination.totalPages - 1)

                                Menu {
                                    ForEach(SortOption.allCases, id: \.self) { option in
                                        Button(action: {
                                            selectedSort = option
                                        }) {
                                            Label(option.rawValue, systemImage: selectedSort == option ? "checkmark" : "")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .foregroundColor(.white)
                                        .font(.system(size: 13, weight: .medium))
                                        .frame(width: 20, height: 20)
                                        .background(Circle().fill(Color.blue))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .background(Color("#131313"))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.white.opacity(0.08)),
                        alignment: .bottom
                    )

                    Spacer()
                }
                .ignoresSafeArea(edges: .top)

                VStack(spacing: 16) {
                    Spacer()

                    HStack {
                        FilterBottomBar()
                            .fixedSize()
                            .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}