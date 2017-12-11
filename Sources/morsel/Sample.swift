import Foundation

public enum AVSampleType: UInt8, BinaryEncodable {
    case video    = 0x75 // v
    case audio    = 0x61 // a
}

public protocol Sample {
    var type: AVSampleType { get }
    var data: [UInt8] { get }
    var size: UInt32 { get }
    var duration: Int64 { get }
    var durationInSeconds: Double { get }
    
    var decode: Double { get set }
    var timescale: UInt32 { get }
    var isSync: Bool { get }
}

extension Sample {
    public var durationInSeconds: Double {
        return Double(self.duration) / Double(self.timescale)
    }
}

protocol MediaFormat { }
#if os(Linux)
#else
import CoreMedia
extension CMFormatDescription: MediaFormat { }
extension AudioStreamBasicDescription: MediaFormat { }
#endif

public struct VideoDimensions {
    var width: UInt32
    var height: UInt32
    
    public init(from data: [UInt8]) {
        self.width  = UInt32(bytes: Array(data[1..<5]))!
        self.height = UInt32(bytes: Array(data[5..<data.count]))!
    }
}

public struct VideoSample: Sample {
    
    public var type: AVSampleType
    public var nalus: [NALU] = []
    
    public var data: [UInt8] {
        var results: [UInt8] = []
        for nalu in nalus {
            results.append(contentsOf: nalu.data)
        }
        return results
    }
    
    public var duration: Int64          = 0
    public var durationSeconds: Double  = 0
    public var decode: Double           = 0
    public var timescale: UInt32        = 0
    
    public var size: UInt32 { return self.nalus.reduce(0, { last, nalu in last + nalu.totalSize }) }
    
    public var dependsOnOthers: Bool            = false
    public var isSync: Bool                     = false
    public var earlierDisplayTimesAllowed: Bool = false
    
    public init(bytes: [UInt8]) {
        self.type                       = .video
        self.isSync                     = bytes[1].toBool()
        self.dependsOnOthers            = bytes[2].toBool()
        self.earlierDisplayTimesAllowed = bytes[3].toBool()
        self.duration                   = Int64(bytes: Array(bytes[4..<12]))!
        self.timescale                  = UInt32(bytes: Array(bytes[12..<16]))!
        self.durationSeconds            = Double(duration) / Double(timescale)
        
        let videoBytes = Array(bytes[16..<bytes.count])
        for nalu in NALUStreamIterator(streamBytes: videoBytes, currentIdx: 0) {
            self.nalus.append(nalu)
        }
    }
    
}

public struct AudioSample: Sample {
    
    public let type: AVSampleType
    public let data: [UInt8]
    
    public var size: UInt32 {
        return UInt32(self.data.count)
    }
    
    public var duration: Int64          = 0
    public var durationSeconds: Double  = 0
    public var decode: Double           = 0
    public var timescale: UInt32        = 0
        
    public var isSync: Bool = false

    public let sampleSize: UInt16
    public let channels: UInt32
    public let sampleRate: Double
    
    public init(bytes: [UInt8]) {
        self.type            = .audio
        self.duration        = Int64(bytes: Array(bytes[1..<9]))!
        self.timescale       = UInt32(bytes: Array(bytes[9..<13]))!
        self.durationSeconds = Double(duration) / Double(timescale)
        
        self.sampleSize = 16
        self.channels   = 1
        self.sampleRate = Double(self.timescale)
        
        let audioBytes = Array(bytes[13..<bytes.count])
        self.data      = audioBytes
    }
    
}

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

