import grip

// The handler reference atom specifies the media handler component that is to be used to interpret the media’s data.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_031.gif

struct HDLR: BinarySizedEncodable {
    
    var type: Atom = .hdlr
    
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    // This is supposed to be either media or data, but the Apple HLS tools sets it to zero for some reason
    var componentType: UInt32 = 0
    var componentSubtype: AtomDataType = .video
    var componentManufacturer: UInt32 = 0
    var componentFlags: UInt32 = 0
    var componentFlagMask: UInt32 = 0
    
    var componentName: String = "krad.tv - morsel\0"
    
    static func with(sampleType: CompressedSampleType) -> HDLR {
        var hdlr = HDLR()
        
        if sampleType == .video {
            hdlr.componentName    = "krad - morsel - video\0"
            hdlr.componentSubtype = .video
        } else {
            hdlr.componentName    = "krad - morsel - audio\0"
            hdlr.componentSubtype = .sound
        }
        
        return hdlr
    }
    
}

enum HDLRComponentType: String, BinaryEncodable {
    case mediaHandler = "mhlr"
    case dataHandler  = "dhlr"
}
