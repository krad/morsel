import Foundation

enum RepresentationError: Error {
    case unknownProfile
}

internal class Representation {
    
    var name: String
    var state: StreamState
  
    var videoSettings: VideoSettings?
    let targetDuration: Double
    
    var duration: Double {
        return self.segments.reduce(0) { cnt, segment in cnt + segment.duration }
    }
    
    internal private(set) var segments: [Segment] = []

    internal init(name: String,
                  videoSettings: VideoSettings?,
                  targetDuration: Double)
    {
        self.name           = name
        self.state          = .starting
        self.videoSettings  = videoSettings
        self.targetDuration = targetDuration
    }
    
    internal func add(segment: Segment) {
        self.segments.append(segment)
    }
    
}
