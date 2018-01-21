import Foundation

protocol Playlist {
    init(fileName: String)
    var type: PlaylistType { get }
    var output: String { get }
}

public enum PlaylistType: String {
    case hls_vod    = "VOD"
    case hls_live   = "LIVE"
    case hls_event  = "EVENT"
}

protocol PlaylistWriter {
    func positionToSeek() -> UInt64?
    func header(with targetDuration: Double) -> String
    func writeSegment(with filename: String, duration: Float64, and firstMediaSequence: Int) -> String
    func end() -> String
}

public enum HLSPlaylistType: String {
    case vod   = "VOD"
    case live  = "LIVE"
    case event = "EVENT"
}
