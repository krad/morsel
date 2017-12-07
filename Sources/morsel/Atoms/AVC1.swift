// FIXME
struct AVC1: BinarySizedEncodable {
    
    let type: Atom = .avc1
    
    var reserved: [UInt8] = [0, 0, 0, 0, 0 ,0]
    
    var dataReferenceIndex: UInt16 = 1
    var version: UInt16 = 0
    var revisionLevel: UInt16 = 0
    var vendor: UInt32 = 0
    var temporalQuality: UInt32 = 0
    var spatialQuality: UInt32 = 0
    
    var width: UInt16 = 1281
    var height: UInt16 = 721
    var horizontalResolution: UInt32 = 4718592
    var verticalResolution: UInt32 = 4718592
    
    var dataSize: UInt32 = 0
    var frameCount: UInt16 = 1
    var compressorNameSize: UInt8 = 0
    var padding: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0]
    
    var depth: UInt16 = 24
    var colorTableID: UInt16 = 65535

    var avcC: [AVCC] = [AVCC()]
    var colr: [COLR] = [COLR()]
    var pasp: [PASP] = [PASP()]
    
    static func from(_ config: MOOVVideoSettings) -> AVC1 {
        var avc1    = AVC1()
        avc1.width  = UInt16(config.width)
        avc1.height = UInt16(config.height)
        avc1.avcC   = [AVCC.from(config)]
        return avc1
    }
}
