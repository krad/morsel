struct MP4A: BinarySizedEncodable {
    
    let type: Atom         = .mp4a
    var reservedA: [UInt8] = [0, 0, 0, 0, 0, 0]
    var dataRefIdx: UInt16 = 1
    
    var reservedB: [UInt32] = [0, 0]

    var channels: UInt16   = 2
    var sampleSize: UInt16 = 16
    
    var predefined: UInt16 = 0
    var reservedC: UInt16  = 0
    
    var sampleRate: UInt32 = 44100 << 16

    var esds: [ESDS]       = [ESDS()]
    
    static func from(_ config: MOOVAudioSettings) -> MP4A {
        var mp4a         = MP4A()
        mp4a.sampleSize = config.sampleSize
        mp4a.sampleRate = config.sampleRate << 16
        mp4a.esds       = [ESDS()]
        return mp4a
    }
    
}
