protocol Codec {
    var name: String { get }
}


enum VideoCodec: Codec {
    case h264(profile: VideoCodecProfile, constraint: UInt8, level: UInt8)
    
    static func parse(_ name: String) -> VideoCodec? {
        if let rfc = RFC6381.parse(name) {
            switch rfc.codec {
            case "avc1":
                if let profile = VideoCodecProfile(rawValue: rfc.profile) {
                    return .h264(profile: profile,
                                 constraint: rfc.constraint,
                                 level: rfc.level)
                }
            default:
                return nil
            }
            
        }
        return nil
    }
    
    var name: String {
        switch self {
        case .h264(let profile, let constraint , let level):
            let params = [profile.rawValue, constraint, level].map { String(format:"%02X", $0) }.joined()
            return "avc1.\(params)"
        }
    }
    
}

enum VideoCodecProfile: UInt8 {
    case h264_baseline  = 0x42
    case h264_main      = 0x4d
    case h264_extended  = 0x58
    case h264_high      = 0x64
}

internal struct RFC6381 {
    
    var codec: String
    var profile: UInt8
    var constraint: UInt8
    var level: UInt8
    
    internal static func parse(_ name: String) -> RFC6381? {
        let comps = name.components(separatedBy: ".")
        if let name = comps.first {
            if let specs = comps.last {
                guard specs != name && specs.pairs.count == 3 else { return nil }
                
                if let profile = UInt8(specs.pairs[0], radix: 16) {
                    if let constraint = UInt8(specs.pairs[1], radix: 16) {
                        if let level = UInt8(specs.pairs[2], radix: 16) {
                            return RFC6381(codec: name,
                                           profile: profile,
                                           constraint: constraint,
                                           level: level)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
}

extension String {
    
    var pairs: [String] {
        var result: [String] = []
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: 2).forEach {
            result.append(String(characters[$0..<min($0+2, characters.count)]))
        }
        return result
    }
    
}
