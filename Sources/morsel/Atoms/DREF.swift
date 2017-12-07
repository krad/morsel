struct DREF: BinarySizedEncodable {
    
    let type: Atom = .dref
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    var numberOfEntries: UInt32 = 1
    var references: [DREFReference] = [DREFReference()]
}

struct DREFReference: BinarySizedEncodable {
    
    var type: DREFType = .url
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 1]
    
}

enum DREFType: String, BinaryEncodable {
    case alis = "alis"
    case rsrc = "rsrc"
    case url  = "url "
}
