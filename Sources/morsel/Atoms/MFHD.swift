// This is used in the moof to convey the sequence number
struct MFHD: BinarySizedEncodable {
    
    let type: Atom = .mfhd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var sequenceNumber: UInt32
    
    init(sequenceNumber: UInt32 = 1) {
        self.sequenceNumber = sequenceNumber
    }
    
}
