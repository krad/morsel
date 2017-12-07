import Foundation

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
