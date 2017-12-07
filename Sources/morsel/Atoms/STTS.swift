// Time-to-Sample Atom
// You can determine the appropriate sample for any time in a media by examining the time-to-sample atom
// table, which is contained in the time-to-sample atom.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_106.gif
struct STTS: BinarySizedEncodable {
    
    let type: Atom = .stts
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    var numberOfEntries: UInt32 = 0
    
}
