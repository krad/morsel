// The track header atom specifies the characteristics of a single track within a movie. A track header atom contains a size field that specifies the number of bytes and a type field that indicates the format of the data (defined by the atom type 'tkhd').
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_096.gif

struct TKHD: BinarySizedEncodable {
    
    let type: Atom = .tkhd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 1]
    
    var creationTime: UInt32     = 3592932068
    var modificationTime: UInt32 = 3592932068

    var trackID: UInt32     = 2
    var reservedA: UInt32   = 0
    var duration: UInt32    = 0
    var reservedB: UInt64   = 0
    
    var layer: UInt16 = 0
    var alternateGroup: UInt16 = 0
    
    var volume: UInt16 = 0x0100
    var reservedC: UInt16 = 0
    
    var matrixStructure: [UInt8] = [0, 1, 0, 0, 0, 0, 0, 0,
                                    0, 0, 0, 0, 0, 0, 0, 0,
                                    0, 1, 0, 0, 0, 0, 0, 0,
                                    0, 0, 0, 0, 0, 0, 0, 0,
                                    64, 0, 0, 0]

    var trackWidth: UInt32  = 1980 << 16
    var trackHeight: UInt32 = 720 << 16
    
    static func from(_ config: MOOVVideoSettings) -> TKHD {
        var tkhd         = TKHD()
        tkhd.trackID     = 1
        tkhd.trackWidth  = config.width << 16
        tkhd.trackHeight = config.height << 16
        return tkhd
    }
    
    static func from(_ config: MOOVAudioSettings) -> TKHD {
        var tkhd         = TKHD()
        tkhd.trackID     = 2
        tkhd.trackWidth  = 0
        tkhd.trackHeight = 0
        return tkhd
    }
    
    
}
