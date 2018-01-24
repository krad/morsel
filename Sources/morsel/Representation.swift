import Foundation

enum RepresentationError: Error {
    case unknownProfile
}

internal class Representation {
    
    var name: String
    var state: StreamState
  
    var videoSettings: VideoSettings?
    let targetDuration: Double
    
    internal private(set) var segments: [Segment] = []
    internal private(set) var playlists: [PlaylistWriter] = []
    
    var duration: Double {
        return self.segments.reduce(0) { cnt, segment in cnt + segment.duration }
    }
    
    internal init(name: String,
                  targetDuration: Double)
    {
        self.name           = name
        self.targetDuration = targetDuration
        self.state          = .starting
    }
    
    internal func add(segment: Segment) {
        self.segments.append(segment)
    }
    
    internal func add(writer: PlaylistWriter) {
        self.playlists.append(writer)
    }
    
}
