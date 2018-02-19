import Foundation
import grip

protocol MediaFormat { }
#if os(Linux)
#else
import CoreMedia
extension CMFormatDescription: MediaFormat { }
extension AudioStreamBasicDescription: MediaFormat { }
#endif


enum AudioObjectType: UInt8 {
    case AAC_Main     = 1
    case AAC_LC       = 2
    case AAC_SSR      = 3
    case AAC_LTP      = 4
    case AAC_SBR      = 5
    case AAC_Scalable = 6
    case TWIN_VQ      = 7
    case CELP         = 8
    case HVXC         = 9
}

enum SamplingFrequency: UInt8 {
    
    case hz96000 = 0
    case hz88200 = 1
    case hz64000 = 2
    case hz48000 = 3
    case hz44100 = 4
    case hz32000 = 5
    case hz24000 = 6
    case hz22050 = 7
    case hz16000 = 8
    case hz12000 = 9
    case hz11025 = 10
    case hz8000  = 11
    case hz7350  = 12
    
    init(sampleRate: Double) {
        switch Int(sampleRate) {
        case 96000:
            self = .hz96000
        case 88200:
            self = .hz88200
        case 64000:
            self = .hz64000
        case 48000:
            self = .hz48000
        case 32000:
            self = .hz32000
        case 24000:
            self = .hz24000
        case 22050:
            self = .hz22050
        case 16000:
            self = .hz16000
        case 12000:
            self = .hz12000
        case 11025:
            self = .hz11025
        case 8000:
            self = .hz8000
        case 7350:
            self = .hz7350
        default:
            self = .hz44100
        }
    }
    
}

enum ChannelConfiguration: UInt8 {
    case frontCenter                                                                           = 1
    case frontLeftAndFrontRight                                                                = 2
    case frontCenterAndFrontLeftAndFrontRight                                                  = 3
    case frontCenterAndFrontLeftAndFrontRightAndBackCenter                                     = 4
    case frontCenterAndFrontLeftAndFrontRightAndBackLeftAndBackRight                           = 5
    case frontCenterAndFrontLeftAndFrontRightAndBackLeftAndBackRightLFE                        = 6
    case frontCenterAndFrontLeftAndFrontRightAndSideLeftAndSideRightAndBackLeftAndBackRightLFE = 7
}

public func ==(lhs: VideoSettings, rhs: VideoSettings) -> Bool {
    if lhs.sps == rhs.sps {
        if lhs.pps == rhs.pps {
            if lhs.width == rhs.width {
                if lhs.height == rhs.height {
                    if lhs.timescale == rhs.timescale {
                        return true
                    }
                }
            }
        }
    }
    return false
}

extension VideoSettings: Equatable { }
