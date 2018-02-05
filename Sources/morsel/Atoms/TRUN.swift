struct TRUN: BinarySizedEncodable {
    
    let type: Atom          = .trun    
    var trFlags: TRUNFlags  = [.dataOffsetPresent,
                               .sampleDurationPresent,
                               .sampleSizePresent,
                               .sampleFlagsPresent]
    
    var sampleCount: UInt32 = 0
    var dataOffset: Int32   = 0
    
    var samples: [TRUNSample] = []
    
    static func from(samples: [VideoSample]) -> TRUN {
        var trun     = TRUN()
        trun.samples = samples.map { TRUNSample($0) }
        trun.sampleCount = UInt32(trun.samples.count)
        return trun
    }
    
    static func from(samples: [AudioSample]) -> TRUN {
        var trun         = TRUN()
        trun.trFlags     = [.dataOffsetPresent, .sampleSizePresent]
        trun.samples     = samples.map { TRUNSample($0) }
        trun.sampleCount = UInt32(trun.samples.count)
        return trun
    }
    
}

struct TRUNFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let dataOffsetPresent                   = TRUNFlags(rawValue: 0x000001)
    static let firstSampleFlagsPresent             = TRUNFlags(rawValue: 0x000004)
    static let sampleDurationPresent               = TRUNFlags(rawValue: 0x000100)
    static let sampleSizePresent                   = TRUNFlags(rawValue: 0x000200)
    static let sampleFlagsPresent                  = TRUNFlags(rawValue: 0x000400)
    static let sampleCompositionTimeOffsetsPresent = TRUNFlags(rawValue: 0x000800)
}

struct TRUNSample: BinaryEncodable {
    
    var duration: UInt32?
    var size: UInt32 = 0
    var flags: SampleFlags?
    
    init(_ sample: VideoSample) {
        self.duration              =  UInt32(sample.duration)
        self.size                  =  sample.size
        self.flags                 = []
        
        if sample.isSync          { self.flags?.insert(.sampleIsDependedOn) }
        if sample.dependsOnOthers { self.flags?.insert(.sampleDependsOn) }
    }
    
    init(_ sample: AudioSample) {
        self.size     = sample.size
    }
}

struct SampleFlags: BinaryEncodable, OptionSet {
    var rawValue: UInt32
    static let sampleDependsOn    = SampleFlags(rawValue: 0x01000000)
    static let sampleIsDependedOn = SampleFlags(rawValue: 0x02000000)
}

