struct MOOVConfig {
    
    var videoSettings: VideoSettings?
    var audioSettings: MOOVAudioSettings?
    
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

struct MOOVAudioSettings {
    
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
    
//    init(_ sample: Sample) {
//        let format = sample.format as! AudioStreamBasicDescription
//        
//        self.channels   = format.mChannelsPerFrame
//        self.sampleRate = sample.timescale
//        
//        self.audioObjectType  = AudioObjectType(objectID: MPEG4ObjectID(rawValue: Int(format.mFormatFlags))!)
//        self.channelLayout    = ChannelConfiguration(rawValue: UInt8(format.mChannelsPerFrame))!
//        self.samplingFreq     = SamplingFrequency(sampleRate: format.mSampleRate)
//    }
    
}



