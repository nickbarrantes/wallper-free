import Foundation
import SwiftUI
import AppKit

struct VideoData: Identifiable, Codable, Equatable {
    let id: String
    var url: String
    var author: String?
    var likes: Int
    var category: String?
    var age: String?
    var createdAt: String?
    var duration: Int?
    var resolution: String?
    var sizeMB: Double?
    var name: String?
    var isPrivate: Bool?
}

struct RawVideoMetadata: Codable {
    let id: String
    let likes: Int?
    let author: String?
    let category: String?
    let createdAt: String?
    let age: String?
    let duration: Int?
    let resolution: String?
    let sizeMB: Double?
    let name: String?
}


@MainActor
class VideoLibraryStore: ObservableObject {
    @Published var wallpapersVideos: [VideoData] = []
    @Published var userGeneratedVideos: [VideoData] = []
    @Published var allVideos: [VideoData] = []
    @Published var downloadedVideos: [VideoData] = []
    @Published var likedVideos: [VideoData] = []
    @Published var isLoaded: Bool = false
    @Published var localFolderPath: String?

    private static let likedKey = "liked_video_ids"
    private static let localFolderKey = "local_folder_path"

    func loadAll() async {
        loadLocalVideos()
        loadLikedVideos()
        loadCachedVideos()
        isLoaded = true
    }
    
    func loadLocalVideos() {
        // Load the saved folder path
        localFolderPath = UserDefaults.standard.string(forKey: Self.localFolderKey)
        
        guard let folderPath = localFolderPath,
              FileManager.default.fileExists(atPath: folderPath) else {
            // No folder selected or folder doesn't exist
            wallpapersVideos = []
            userGeneratedVideos = []
            allVideos = []
            return
        }
        
        let folderURL = URL(fileURLWithPath: folderPath)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles])
            
            let videoFiles = contents.filter { url in
                let ext = url.pathExtension.lowercased()
                return ["mp4", "mov", "m4v", "avi", "mkv"].contains(ext)
            }
            
            let videos: [VideoData] = videoFiles.map { url in
                let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map { Double($0) / (1024 * 1024) }
                
                return VideoData(
                    id: url.lastPathComponent,
                    url: url.absoluteString,
                    author: "Local",
                    likes: 0,
                    category: "Local Videos",
                    age: "0+",
                    createdAt: nil,
                    duration: nil,
                    resolution: nil,
                    sizeMB: fileSize,
                    name: url.lastPathComponent,
                    isPrivate: false
                )
            }
            
            wallpapersVideos = videos
            userGeneratedVideos = []
            allVideos = videos
            
        } catch {
            print("❌ Error loading local videos: \(error.localizedDescription)")
            wallpapersVideos = []
            userGeneratedVideos = []
            allVideos = []
        }
    }
    
    func selectLocalFolder() -> Bool {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Select Video Folder"
        panel.prompt = "Select"
        
        if panel.runModal() == .OK, let url = panel.url {
            localFolderPath = url.path
            UserDefaults.standard.set(url.path, forKey: Self.localFolderKey)
            loadLocalVideos()
            return true
        }
        return false
    }


    func loadLikedVideos() {
        let likedIDs = Self.allLikedIDs()
        self.likedVideos = allVideos.filter { likedIDs.contains($0.id) }
    }

    static func allLikedIDs() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: likedKey) ?? [])
    }

    func likeVideo(_ id: String) {
        var liked = Self.allLikedIDs()
        liked.insert(id)
        UserDefaults.standard.set(Array(liked), forKey: Self.likedKey)
        loadLikedVideos()
    }

    func unlikeVideo(_ id: String) {
        var liked = Self.allLikedIDs()
        liked.remove(id)
        UserDefaults.standard.set(Array(liked), forKey: Self.likedKey)
        loadLikedVideos()
    }

    func isLiked(_ id: String) -> Bool {
        Self.allLikedIDs().contains(id)
    }
    
    func likes(for id: String) -> Int {
        allVideos.first(where: { $0.id == id })?.likes ?? 0
    }

    func updateLikes(videoID: String, increment: Int) async {
        // Update likes locally only
        if let index = allVideos.firstIndex(where: { $0.id == videoID }) {
            allVideos[index].likes += increment
        }
    }
    
    func addDownloadedVideo(id: String) {
        let filename = "\(id).mp4"
        let videosDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Wallper/Videos", isDirectory: true)
        let path = videosDir.appendingPathComponent(filename).path

        print("📂 Looking for file in directory: \(videosDir.path)")

        guard FileManager.default.fileExists(atPath: path) else {
            print("🚫 File not found: \(filename)")
            return
        }

        guard let video = allVideos.first(where: { $0.id == id }) else {
            print("❌ No matching video in allVideos for id: \(id)")
            return
        }

        if !downloadedVideos.contains(where: { $0.id == id }) {
            downloadedVideos.append(video)
            print("✅ Added \(id) to downloadedVideos (total: \(downloadedVideos.count))")
        }
    }


    func loadCachedVideos() {
        let appSupportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Wallper/Videos", isDirectory: true)

        try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)

        let cachedFiles = (try? FileManager.default.contentsOfDirectory(at: appSupportDir, includingPropertiesForKeys: nil)) ?? []
        let cachedMP4s = cachedFiles.filter { $0.pathExtension.lowercased() == "mp4" }

        let all = allVideos + userGeneratedVideos
        var result: [VideoData] = []

        for fileURL in cachedMP4s {
            let id = fileURL.deletingPathExtension().lastPathComponent

            if let existing = all.first(where: { $0.id == id }) {
                result.append(existing)
            } else {
                result.append(VideoData(
                    id: id,
                    url: fileURL.absoluteString,
                    author: "Local",
                    likes: 0,
                    category: "Custom",
                    age: "0+",
                    createdAt: nil,
                    duration: nil,
                    resolution: nil,
                    sizeMB: nil,
                    name: fileURL.lastPathComponent,
                    isPrivate: true
                ))
            }
        }

        downloadedVideos = result
    }



    
    func importLocalVideo(from url: URL) {
        let id = UUID().uuidString
        let fileExtension = url.pathExtension
        let newFilename = "\(id).\(fileExtension)"

        let appSupportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("Wallper/Videos", isDirectory: true)

        try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)

        let destinationURL = appSupportDir.appendingPathComponent(newFilename)

        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            print("✅ Copied video to \(destinationURL.lastPathComponent)")

            let sizeMB = (try? FileManager.default.attributesOfItem(atPath: destinationURL.path)[.size] as? NSNumber)
                .map { $0.doubleValue / (1024 * 1024) }

            let video = VideoData(
                id: id,
                url: destinationURL.absoluteString,
                author: "Local",
                likes: 0,
                category: "Custom",
                age: "0+",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                duration: nil,
                resolution: nil,
                sizeMB: sizeMB,
                name: url.lastPathComponent,
                isPrivate: true
            )

            if allVideos.contains(where: { $0.id == id }) {
                print("⚠️ Skipping duplicate import of \(id)")
                return
            }

            userGeneratedVideos.insert(video, at: 0)
            allVideos.insert(video, at: 0)
            downloadedVideos.insert(video, at: 0)

        } catch {
            print("❌ Failed to import video:", error.localizedDescription)
        }
    }



}
