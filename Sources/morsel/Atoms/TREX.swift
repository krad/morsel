struct TREX: BinarySizedEncodable {
    
    let type: Atom = .trex
    
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var trackID: UInt32                = 1
    var sampleDescriptionIndex: UInt32 = 1
    var sampleDuration: UInt32         = 0
    var sampleSize: UInt32             = 0
    
    var sampleFlags: SampleFlags = [.sampleIsDependedOn]
    
    static func from(_ config: MOOVVideoSettings) -> TREX {
        var trex     = TREX()
        trex.trackID = 1
        return trex
    }
    
    static func from(_ config: MOOVAudioSettings) -> TREX {
        var trex         = TREX()
        trex.trackID     = 2
        trex.sampleFlags = []
        return trex
    }

}
