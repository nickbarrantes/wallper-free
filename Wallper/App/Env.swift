import Foundation

class Env {
    static let shared = Env()
    
    private init() {}
    
    func loadSyncFromLambda() {
        // No longer needed - keeping for compatibility
    }
    
    func get(_ key: String) -> String? {
        // Return nil for all keys since we no longer use remote config
        return nil
    }
}