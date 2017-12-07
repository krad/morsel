struct SMHD: BinarySizedEncodable {
    
    let type: Atom = .smhd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var balance: UInt16 = 0
    
    var reserved: UInt16 = 0
    
}
