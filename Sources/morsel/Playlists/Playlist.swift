import Foundation

/// Playlist is a struct used to construct a playlist with a certain name of a certain type
public struct Playlist {
    
    /// The type of playlist to be constructed
    public let type: PlaylistType
    
    /// The file name of the playlist to be constructed
    public let fileName: String
    
    public init(type: PlaylistType, fileName: String) {
        self.type     = type
        self.fileName = fileName
    }
    
}

/// The types of Playlist's the can be constructed
///
/// - hls_vod: HLS VOD playlist
/// - hls_live: HLS Live playlist
/// - hls_event: HLS Event playlist
public enum PlaylistType: String {
    
    // HLS Video on Demand (VOD) playlist
    case hls_vod    = "VOD"
    
    // HLS Live (Sliding Window) playlist
    case hls_live   = "LIVE"
    
    // HLS Event playlist
    case hls_event  = "EVENT"
    
}

protocol PlaylistGenerator {
    init(fileName: String)
    var type: PlaylistType { get }
    var output: String { get }
    var representation: Representation? { get set }
}
