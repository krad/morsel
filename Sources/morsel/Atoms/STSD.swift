// FIXME
struct STSD: BinarySizedEncodable {
    
    let type: Atom = .stsd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var numberOfEntries: UInt32 = 1
    
    var avc1: [AVC1]?
    var mp4a: [MP4A]?
    
    static func from(_ config: VideoSettings) -> STSD {
        var stsd = STSD()
        stsd.avc1 = [AVC1.from(config)]
        stsd.mp4a = nil
        return stsd
    }
    
    static func from(_ config: AudioSettings) -> STSD {
        var stsd    = STSD()
        stsd.avc1   = nil
        stsd.mp4a   = [MP4A.from(config)]
        return stsd
    }
    
}
