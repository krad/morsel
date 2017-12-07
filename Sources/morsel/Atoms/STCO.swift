// Chunk offset atoms identify the location of each chunk of data in the media’s data stream.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_112.gif
// We shouldn't need any chunk entries for fragmented mp4

struct STCO: BinarySizedEncodable {
    
    let type: Atom = .stco
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var numberOfEntries: UInt32 = 0
}
