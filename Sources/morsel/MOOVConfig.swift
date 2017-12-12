struct MOOVConfig {
    
    var videoSettings: VideoSettings?
    var audioSettings: AudioSettings?
    
    init() { }
    
}

public struct VideoSettings {
    var sps: [UInt8]
    var pps: [UInt8]
    var width: UInt32
    var height: UInt32
    var timescale: UInt32 = 30000
    
    public init(params: [[UInt8]], dimensions: VideoDimensions, timescale: UInt32) {
        self.sps        = params.first == nil ? [] : params.first!
        self.pps        = params.last  == nil ? [] : params.last!
        self.width      = dimensions.width
        self.height     = dimensions.height
        self.timescale  = timescale
    }
}

public struct AudioSettings {
    
    var channels: UInt32   = 2
    var sampleRate: UInt32 = 44100
    var sampleSize: UInt16 = 16
    var audioObjectType: AudioObjectType
    var samplingFreq: SamplingFrequency
    var channelLayout: ChannelConfiguration
    
    init(audioObjectType: AudioObjectType,
         samplingFreq: SamplingFrequency,
         channelLayout: ChannelConfiguration)
    {
        self.audioObjectType = audioObjectType
        self.samplingFreq    = samplingFreq
        self.channelLayout   = channelLayout
    }
    
    public init(_ sample: AudioSample) {
        self.channels   = sample.channels
        self.sampleRate = UInt32(sample.sampleRate)
        
        self.audioObjectType = AudioObjectType.AAC_Main
        self.channelLayout   = ChannelConfiguration(rawValue: UInt8(sample.channels))!
        self.samplingFreq    = SamplingFrequency(sampleRate: sample.sampleRate)
    }

}



