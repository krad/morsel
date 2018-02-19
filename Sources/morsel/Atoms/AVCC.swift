import grip

// AVC Decoder Configuration
struct AVCC: BinarySizedEncodable {
    
    let type: Atom = .avcC
    
    var version: UInt8 = 1
    var profile: UInt8 = 0x42 // 66 Baseline
    var profileCompatibility: UInt8 = 0
    var levelIndication: UInt8 = 30
    
    // 5 bits reserved (all on)
    // 2 bits NALUnitLength field in the parameter set minus 1; 0b11 = 3
    var naluSize: UInt8   = 0b11111111
    
    // 3 bits revserved (all on)
    // 5 bits sps count
    var spsCount: UInt8   = 0b11100001
    var spsLength: UInt16 = 27
    
    var sps: [SPS] = [SPS(data: [0x27, 0x4d, 0x00, 0x1f, 0x89, 0x8b,
                                 0x60, 0x28, 0x02, 0xdd, 0x80, 0xb5,
                                 0x01, 0x01, 0x01, 0xec, 0x0c, 0x00,
                                 0x17, 0x70, 0x00, 0x05, 0xdc, 0x17,
                                 0xbd, 0xf0, 0x50])]
    
    var ppsCount: UInt8 = 1
    var ppsLength: UInt16 = 4
    var pps: [PPS] = [PPS(data: [0x28, 0xee, 0x1f, 0x20])]
    
    static func from(_ config: VideoSettings) -> AVCC {
        var avcc = AVCC()
        avcc.profile              = config.sps[1]
        avcc.profileCompatibility = config.sps[2]
        avcc.levelIndication      = config.sps[3]
        avcc.sps                  = [SPS(data: config.sps)]
        avcc.spsLength            = UInt16(config.sps.count)
        avcc.pps                  = [PPS(data: config.pps)]
        avcc.ppsCount             = 1
        avcc.ppsLength            = UInt16(config.pps.count)
        return avcc
    }
    
}

struct SPS: BinaryEncodable {
    var data: [UInt8]
}

struct PPS: BinaryEncodable {
    var data: [UInt8]
}
