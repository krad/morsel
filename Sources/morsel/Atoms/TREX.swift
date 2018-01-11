struct TREX: BinarySizedEncodable {
    
    let type: Atom = .trex
    
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var trackID: UInt32                = 1
    var sampleDescriptionIndex: UInt32 = 1
    var sampleDuration: UInt32         = 0
    var sampleSize: UInt32             = 0
    
    //var sampleFlags: SampleFlags = [.sampleIsDependedOn]
    var sampleFlags: UInt32 = 0
    
    static func from(_ config: VideoSettings) -> TREX {
        var trex     = TREX()
        trex.trackID = 1
        trex.sampleFlags = 1010000
        return trex
    }
    
    static func from(_ config: AudioSettings) -> TREX {
        var trex         = TREX()
        trex.trackID     = 2
//        trex.sampleFlags = []
        return trex
    }

}
