import Foundation

class HLSVODPlaylist: PlaylistWriter {
    
    private var firstMediaSequence: Int = 1
    
    func positionToSeek() -> UInt64? {
        return nil
    }
    
    func header(with targetDuration: Double) -> String {
        return [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(Int64(targetDuration))",
            "#EXT-X-VERSION:7",
            "#EXT-X-MEDIA_SEQUENCE:\(self.firstMediaSequence)",
            "#EXT-X-PLAYLIST-TYPE:VOD",
            "#EXT-X-INDEPENDENT-SEGMENTS",
            "#EXT-X-MAP:URI=\"fileSeq0.mp4\"\n"
        ].joined(separator: "\n")
    }
    
    func writeSegment(with filename: String, duration: Float64, and firstMediaSequence: Int) -> String {
        self.firstMediaSequence = firstMediaSequence
        return segmentEntry(fileName: filename, duration: duration) + "\n"
    }
    
    func end() -> String {
        return "#EXT-X-ENDLIST\n"
    }
    
}

