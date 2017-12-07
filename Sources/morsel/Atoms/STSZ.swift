// The sample size atom contains the sample count and a table giving the size of each sample.
// This allows the media data itself to be unframed. The total number of samples in the media
// is always indicated in the sample count. If the default size is indicated, then no table follows.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_108.gif

struct STSZ: BinarySizedEncodable {
    
    let type: Atom = .stsz
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var sampleSize: UInt32 = 0
    var numberOfEntries: UInt32 = 0
    
}
