import Foundation

class HLSEventPlaylist: Playlist {

    var type: PlaylistType = .hls_event
    internal var representation: Representation?
    internal var fileName: String

    required init(fileName: String) {
        self.fileName = fileName
    }

    var output: String {
        guard let representation = self.representation else { return "" }
        
        var firstInitSegmentWrote = false

        let segments: [String] = representation.segments.map {
            if $0.isIndex {
                let initStr = "#EXT-X-MAP-URI=\"\($0.url.lastPathComponent)\""
                if firstInitSegmentWrote {
                    return "#EXT-X-DISCONTINUITY\n\(initStr)"
                }
                else {
                    firstInitSegmentWrote = true
                    return initStr
                }
            } else {
                return "#EXTINF:\($0.duration),\n\($0.url.lastPathComponent)"
            }
        }
        
        var result = header + segments
        if representation.state == .done {
            result += endTag
        }
        
        return result.joined(separator: "\n")
    }
    
    private var header: [String] {
        guard let representation = self.representation else { return [] }
        
        return [
            "#EXTM3U",
            "#EXT-X-TARGETDURATION:\(Int64(representation.targetDuration))",
            "#EXT-X-VERSION:7",
            "#EXT-X-MEDIA_SEQUENCE:1",
            "#EXT-X-PLAYLIST-TYPE:\(self.type.rawValue)",
            "#EXT-X-INDEPENDENT-SEGMENTS"]
    }
    
    private var endTag: [String] {
        return ["#EXT-X-ENDLIST\n"]
    }
    


    
}
