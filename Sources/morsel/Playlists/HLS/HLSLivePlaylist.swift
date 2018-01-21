import Foundation

class HLSLivePlaylist: Playlist {
    
    var type: PlaylistType = .hls_live
    internal var representation: Representation?
    internal var fileName: String

    required init(fileName: String) {
        self.fileName = fileName
    }
    
    var output: String {
        guard let representation = self.representation,
              representation.segments.count > 0 else { return "" }
        
        var firstInitSegmentWrote = false

        let segments: [String] = self.getLastSegments(in: representation).map {
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
        
        return (header + segments).joined(separator: "\n")
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
    
    private func getLastSegments(in representation: Representation) -> [Segment] {
        var result: [Segment] = []
        
        let segmentIndices: [Segment] = representation.segments.filter { $0.isIndex == true }
        let lastSegments: [Segment]   = Array(representation.segments.suffix(3))
        
        let segmentsContainIndex: Bool = (lastSegments.filter { $0.isIndex == true }.count > 0)
        
        if segmentsContainIndex {
            if let lastIndex = segmentIndices.last {
                if let firstIndex = segmentIndices.dropLast().last {
                    if lastIndex == firstIndex {
                        result = [lastIndex] + lastSegments
                    } else {
                        if let firstLastSegment = lastSegments.first {
                            if firstLastSegment.isIndex {
                                result = lastSegments
                            } else {
                                result = [firstIndex] + lastSegments
                            }
                        }
                    }
                }
            }
            
            if result.count == 0 {
                result = lastSegments
            }
            
        } else {
            if let lastIndex = segmentIndices.last {
                result = [lastIndex] + lastSegments
            } else {
                result = lastSegments
            }
        }
        
        return result
    }
    
}
