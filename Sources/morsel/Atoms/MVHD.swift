// The data contained in this atom defines characteristics of the entire QuickTime movie, such as time scale and duration. It has an atom type value of 'mvhd'.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_095.gif

struct MVHD: BinarySizedEncodable {
    
    let type: Atom      = .mvhd
    var version: UInt8  = 0
    var flags: [UInt8]  = [0, 0, 0]
    
    var creationTime: UInt32     = 3592932068
    var modificationTime: UInt32 = 3592932068
    
    var timeScale: UInt32 = 30
    var duration: UInt32  = 0
    
    var preferredRate: UInt32   = 0x00010000
    var preferredVolume: Int16  = 0x0100
    
    var reserved: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    var matrixStructure: [UInt8] = [0, 1, 0, 0, 0, 0, 0, 0,
                                    0, 0, 0, 0, 0, 0, 0, 0,
                                    0, 1, 0, 0, 0, 0, 0, 0,
                                    0, 0, 0, 0, 0, 0, 0, 0,
                                    64, 0, 0, 0]
    
    var previewTime: UInt32 = 0
    var previewDuration: UInt32 = 0
    var posterTime: UInt32 = 0
    var selectionTime: UInt32 = 0
    var selectionDuration: UInt32 = 0
    var currentTime: UInt32 = 0
    var nextTrackID: UInt32 = 2
    
    static func from(_ config: MOOVVideoSettings) -> MVHD {
        var mvhd = MVHD()
        mvhd.timeScale = config.timescale
        return mvhd
    }
    
}
