import Foundation

public struct Playlist {
    public let type: PlaylistType
    public let fileName: String
}

public enum PlaylistType: String {
    case hls_vod    = "VOD"
    case hls_live   = "LIVE"
    case hls_event  = "EVENT"
}

protocol PlaylistGenerator {
    init(fileName: String)
    var type: PlaylistType { get }
    var output: String { get }
    var representation: Representation? { get set }
}
