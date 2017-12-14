// The media header atom specifies the characteristics of a media, including time scale
// and duration. The media header atom has an atom type of 'mdhd'.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_097.gif

struct MDHD: BinarySizedEncodable {
    
    let type: Atom = .mdhd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var creationTime: UInt32 = 3592932068
    var modificationTime: UInt32 = 3592932068
    
    var timeScale: UInt32 = 30000
    var duration: UInt32 = 0
    
    var language: UInt16 = 0x55c4
    var quality: UInt16 = 0
    
    static func from(_ config: VideoSettings) -> MDHD {
        var mdhd = MDHD()
//        mdhd.timeScale = config.timescale
        mdhd.timeScale = 44100 // Weird bug where audio gets out of sync.  Noticed apple also does this.
        return mdhd
    }
    
    static func from(_ config: AudioSettings) -> MDHD {
        var mdhd = MDHD()
        mdhd.timeScale = config.sampleRate
        return mdhd
    }
    
}
