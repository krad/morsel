// Video media information header atoms define specific color and graphics mode information.
// https://developer.apple.com/library/content/documentation/QuickTime/QTFF/art/qt_l_101.gif

struct VMHD: BinarySizedEncodable {
    
    let type: Atom = .vmhd
    
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 1]
    
    var graphicsMode: UInt16 = 0
    
    var opColor: [UInt16] = [0, 0, 0]
    
}
