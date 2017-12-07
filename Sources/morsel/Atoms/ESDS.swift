struct ESDS: BinarySizedEncodable {
    
    let type: Atom = .esds
    
//    var fake: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x03, 0x80, 0x80, 0x80,
//                         0x22, 0x00, 0x00, 0x00, 0x04, 0x80, 0x80, 0x80,
//                         0x14, 0x40, 0x15, 0x00, 0x18, 0x00, 0x00, 0x01,
//                         0xf4, 0x00, 0x00, 0x01, 0xf4, 0x00, 0x05, 0x80,
//                         0x80, 0x80, 0x02, 0x12, 0x10, 0x06, 0x80, 0x80,
//                         0x80, 0x01, 0x02]

    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]

    var esDescTypeTag: UInt8 = 0x03

    var esExtDescTypeTag: [UInt8] = [0x80, 0x80, 0x80] // 0x80 = start & 0xfe = end
    var esDescLength: UInt8 = 0x22

    var esid: UInt16          = 0
    var streamPriority: UInt8 = 0

    var decoderConfigDescTag: UInt8 = 0x04
    var esExtDescTypeTag2: [UInt8] = [0x80, 0x80, 0x80] // 0x80 = start & 0xfe = end
    var esExtDescLenth: UInt8 = 0x14

    var objectProfileIndication: UInt8 = 0x40 // audio = 64
    var streamType: UInt8              = 0x15
    var bufferSizeDB: [UInt8]          = [0x00, 0x18, 0x00]

//    var maxBitRate: [UInt8] = [0x00, 0x01, 0xf4, 0x00, 0x00, 0x01, 0xf4, 0x00]

    var maxBitRate: UInt32         = 0
    var avgBitRate: UInt32         = 0
//    var maxBitRate: UInt32         = 128000
//    var avgBitRate: UInt32         = 128000

    
    var decoderSpecificInfoTag: UInt8 = 0x05

    var esExtDescTypeTag3: [UInt8] = [0x80, 0x80, 0x80] // 0x80 = start & 0xfe = end

    var descTypeLength: UInt8 = 0x02

    var audioSpecificConfig: [UInt8] = [0x12, 0x10]

    var esExtDescTypeTag4: [UInt8] = [0x06, 0x80, 0x80, 0x80]

    var slConfigLen: UInt8 = 0x01
    var slmp4Const: UInt8 = 0x02

    static func from(_ config: MOOVAudioSettings) -> ESDS {
        var esds = ESDS()
        
        let audioSpecificConfig = AudioSpecificConfig(type: config.audioObjectType,
                                                      frequency: config.samplingFreq,
                                                      channel: config.channelLayout)

        esds.audioSpecificConfig = audioSpecificConfig.bytes
        
        return esds
    }
    
}


struct AudioSpecificConfig {
    
    var type: AudioObjectType
    var frequency: SamplingFrequency
    var channel: ChannelConfiguration
    
    var bytes: [UInt8] {
        var bytes:[UInt8] = [UInt8](repeating: 0, count: 2)
        bytes[0] = type.rawValue << 3 | (frequency.rawValue >> 1 & 0x3)
        bytes[1] = (frequency.rawValue & 0x1) << 7 | (channel.rawValue & 0xF) << 3
        return bytes
    }
}
