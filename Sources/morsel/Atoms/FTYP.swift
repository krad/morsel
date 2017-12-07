struct FTYP: BinaryEncodable {
    
    let type: Atom = .ftyp
    var majorBrand: Brand = .mp42
    var minorVersion: UInt32 = 1
    var compatibleBrands: [Brand] = [.mp41, .mp42, .isom, .hlsf]
    
}
