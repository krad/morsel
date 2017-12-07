import CoreMedia

struct MOOVConfig {
    
    var videoSettings: MOOVVideoSettings?
    var audioSettings: MOOVAudioSettings?
    
    init() { }
    
}

struct MOOVVideoSettings {
    
    var sps: [UInt8]
    var pps: [UInt8]
    var width: UInt32
    var height: UInt32
    var timescale: UInt32 = 30000
    
    init(_ sample: Sample) {
        
        let format     = sample.format as! CMFormatDescription
        self.timescale = sample.timescale
        
        /// This is only setup this way for tests
        /// If we get a format description with no param set we're hosed either way
        let paramSet = getVideoFormatDescriptionData(format)
        self.sps = paramSet.first == nil ? [] : paramSet.first!
        self.pps = paramSet.last == nil ? [] : paramSet.last!
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(format)
        self.width     = UInt32(dimensions.width)
        self.height    = UInt32(dimensions.height)
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
    
    init(_ sample: Sample) {
        let format = sample.format as! AudioStreamBasicDescription
        
        self.channels   = format.mChannelsPerFrame
        self.sampleRate = sample.timescale
        
        self.audioObjectType  = AudioObjectType(objectID: MPEG4ObjectID(rawValue: Int(format.mFormatFlags))!)
        self.channelLayout    = ChannelConfiguration(rawValue: UInt8(format.mChannelsPerFrame))!
        self.samplingFreq     = SamplingFrequency(sampleRate: format.mSampleRate)
    }
    
}



