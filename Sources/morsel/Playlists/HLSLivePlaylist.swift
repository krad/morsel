import Foundation

class HLSLivePlayerWriter: PlaylistWriter {
    
    var segments: [(String, Float64, Int)] = []
    private var header: String = ""
    private var numberOfSegments: Int
    private var targetDuration: Double = 0
    private var currentMediaSequence: Int = 1
    
    
    init(numberOfSegments: Int = 6) {
        self.numberOfSegments = numberOfSegments
    }
    
    func positionToSeek() -> UInt64? {
        return 0
    }
    
    func header(with targetDuration: Double) -> String {
        self.targetDuration = targetDuration
        self.header = [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(Int64(targetDuration))",
            "#EXT-X-VERSION:7",
            "#EXT-X-MEDIA-SEQUENCE:\(currentMediaSequence)",
            "#EXT-X-PLAYLIST-TYPE:LIVE",
            "#EXT-X-INDEPENDENT-SEGMENTS",
            "#EXT-X-MAP:URI=\"fileSeq0.mp4\"\n"
            ].joined(separator: "\n")
        return self.header
    }
    
    func writeSegment(with filename: String,
                      duration: Float64,
                      and firstMediaSequence: Int) -> String {
        
        if segments.count == self.numberOfSegments {
            self.segments.removeFirst(1)
            if let firstSegment = self.segments.first {
                self.currentMediaSequence = firstSegment.2
            }
        }
        
        self.segments.append((filename, duration, firstMediaSequence))
        
        let segmentsSection = self.segments.map { entry in
            segmentEntry(fileName: entry.0, duration: entry.1)
        }.joined(separator: "\n") + "\n"
        
        let headerSection = self.header(with: self.targetDuration)
        
        return headerSection + segmentsSection
        
    }
    
    func end() -> String {
        return ""
    }
    
}

func segmentEntry(fileName: String, duration: Double) -> String {
    return "#EXTINF:\(duration),\n\(fileName)"
}
