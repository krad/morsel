// The sample-to-chunk atom contains a table that maps samples to chunks in the media data stream.
// By examining the sample-to-chunk atom, you can determine the chunk that contains a specific sample.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_107.gif

struct STSC: BinarySizedEncodable {
    
    let type: Atom = .stsc
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var numberOfEntries: UInt32 = 0
    
}
