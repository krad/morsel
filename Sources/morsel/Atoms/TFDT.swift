// Track Fragment Decode time
struct TFDT: BinarySizedEncodable {
    
    let type: Atom      = .tfdt
    var version: UInt8  = 1
    var flags: [UInt8]  = [0, 0, 0]
    
    var baseMediaDecodeTime: UInt64 = 0
    
    static func from(decode: Double) -> TFDT {
        var tfdt                   = TFDT()
        tfdt.baseMediaDecodeTime   = UInt64(decode)
        return tfdt
    }
    
}
