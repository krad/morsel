// AVC Decoder Configuration
struct AVCC: BinarySizedEncodable {
    
    let type: Atom = .avcC
    
    var version: UInt8 = 1
    var profile: UInt8 = 77
    var profileCompatibility: UInt8 = 0
    var levelIndication: UInt8 = 31
    
    var naluSize: UInt8   = 3 // NALUnitLength field in the parameter set minus 1
    var spsCount: UInt8   = 0xe1
    var spsLength: UInt16 = 27
    
    var sps: [SPS] = [SPS(data: [0x27, 0x4d, 0x00, 0x1f, 0x89, 0x8b,
                                 0x60, 0x28, 0x02, 0xdd, 0x80, 0xb5,
                                 0x01, 0x01, 0x01, 0xec, 0x0c, 0x00,
                                 0x17, 0x70, 0x00, 0x05, 0xdc, 0x17,
                                 0xbd, 0xf0, 0x50])]
    
    var ppsCount: UInt8 = 1
    var ppsLength: UInt16 = 4
    var pps: [PPS] = [PPS(data: [0x28, 0xee, 0x1f, 0x20])]
    
    static func from(_ config: MOOVVideoSettings) -> AVCC {
        var avcc = AVCC()
        avcc.sps       = [SPS(data: config.sps)]
        avcc.spsCount  = 1
        avcc.spsLength = UInt16(config.sps.count)
        avcc.pps       = [PPS(data: config.pps)]
        avcc.ppsCount  = 1
        avcc.ppsLength = UInt16(config.pps.count)
        return avcc
    }
    
}

struct SPS: BinaryEncodable {
    var data: [UInt8]
}

struct PPS: BinaryEncodable {
    var data: [UInt8]
}
