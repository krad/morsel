import Foundation

enum RepresentationError: Error {
    case unknownProfile
}

internal class Representation {
    
    var name: String
    var state: StreamState
  
    var videoSettings: VideoSettings?
    let targetDuration: TimeInterval
    
    internal private(set) var segments: [Segment] = []
    internal private(set) var playlists: [PlaylistWriter] = []
    
    var duration: TimeInterval {
        return self.segments.reduce(0) { cnt, segment in cnt + segment.duration }
    }
    
    var timescale: UInt32 {
        if let settings = self.videoSettings {
            return settings.timescale
        }
        return 0
    }
    
    internal init(name: String,
                  targetDuration: TimeInterval)
    {
        self.name           = name
        self.targetDuration = targetDuration
        self.state          = .starting
    }
    
    internal func add(segment: Segment) {
        self.state = .live
        self.segments.append(segment)
        self.playlists.forEach { $0.update() }
    }
    
    internal func add(writer: PlaylistWriter) {
        self.playlists.append(writer)
    }
    
}
