// Track Fragment Header
struct TFHD: BinarySizedEncodable {
    
    let type: Atom = .tfhd
    var tfFlags: TrackFragmentFlags = [.defaultBaseIsMOOF,
                                       .defaultSampleDurationPresent,
                                       .sampleDescriptionIndexPresent,
                                       .defaultSampleSizePresent,
                                       .defaultSampleFlagsPresent]
    
    var trackID: UInt32 = 1
    var baseDataOffset: UInt64?
    var sampleDescriptionIndexPresent: UInt32?
    var defaultSampleDuration: UInt32?
    var defaultSampleSize: UInt32?
    var defaultSampleFlags: TrackFragmentFlags?
    
    static func from(sample: VideoSample) -> TFHD {
        var tfhd                           = TFHD()
        tfhd.trackID                       = 1
        tfhd.tfFlags                       = TrackFragmentFlags(rawValue: 0x2003a)
        tfhd.sampleDescriptionIndexPresent = 0
        tfhd.defaultSampleDuration         = UInt32(sample.duration)
        tfhd.defaultSampleSize             = sample.size
        tfhd.defaultSampleFlags            = TrackFragmentFlags(rawValue: 0x2000000)
        return tfhd
    }
    
    static func from(sample: AudioSample) -> TFHD {
        var tfhd                           = TFHD()
        tfhd.trackID                       = 2
        tfhd.tfFlags                       = [.defaultBaseIsMOOF, .sampleDescriptionIndexPresent, .defaultSampleDurationPresent, .defaultSampleSizePresent]
        tfhd.sampleDescriptionIndexPresent = 1
        tfhd.defaultSampleDuration         = UInt32(sample.duration)
        tfhd.defaultSampleSize             = sample.size
        return tfhd
    }
    
}

struct TrackFragmentFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let defaultBaseIsMOOF                = TrackFragmentFlags(rawValue: 0x20000)
    static let baseDataOffsetPresent            = TrackFragmentFlags(rawValue: 0x000001)  // base-data-offset-present
    static let sampleDescriptionIndexPresent    = TrackFragmentFlags(rawValue: 0x000002)  // sample-description-index-present
    static let defaultSampleDurationPresent     = TrackFragmentFlags(rawValue: 0x000008)  // default-sample-duration-present
    static let defaultSampleSizePresent         = TrackFragmentFlags(rawValue: 0x000010)  // default-sample-size-present
    static let defaultSampleFlagsPresent        = TrackFragmentFlags(rawValue: 0x000020)  // default-sample-flags-present
    static let durationIsEmpty                  = TrackFragmentFlags(rawValue: 0x010000)  // duration-is-empty

}
