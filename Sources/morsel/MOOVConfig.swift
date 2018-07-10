import grip

struct MOOVConfig {
    
    var videoSettings: VideoSettings?
    var audioSettings: AudioSettings?
    
    init() { }
    
}

// Video settings is a struct user to configure the video settings for a mp4 writer
public struct VideoSettings {
    
    /// An array of unsigned 8 bit integers that holds the video stream's Sequence Parameter Set (SPS)
    var sps: [UInt8]
    
    // An array of unsigned 8 bit intergers that holds the video stream's Picture Parameter Set (PPS)
    var pps: [UInt8]
    
    // Unsigned 32bit integer describing the width of the video image
    var width: UInt32
    
    // Unsigned 32bit integer describing the height of the video image
    var height: UInt32
    
    // Unsigned 32bit integer describing the timescale of the video stream.
    // This is usually the denominator used in PTS,DTS,etc Rational numbers
    var timescale: UInt32 = 30000
    
    // Human readable string describing the video codec used in the struct.
    var codec: String?
    
    public init(params: [[UInt8]], dimensions: VideoDimensions, timescale: UInt32) {
        self.sps        = params.first == nil ? [] : params.first!
        self.pps        = params.last  == nil ? [] : params.last!
        self.width      = dimensions.width
        self.height     = dimensions.height
        self.timescale  = timescale
        
        if let profile = VideoCodecProfile(rawValue: sps[0]) {
            let videoCodec = VideoCodec.h264(profile: profile, constraint: sps[1], level: sps[2])
            self.codec     = videoCodec.name
        }
    }
}

// AudioSettings is a struct used to configure the audio settings for a mp4 writer
public struct AudioSettings {
    
    // Number of channels in the stream.  Defaults to 2 (stereo)
    var channels: UInt32   = 2
    
    // Sample rate of data in the stream.  Defaults to 44100
    var sampleRate: UInt32 = 44100
    
    // Sample size of samples in the stream. Defaults to 16bit
    var sampleSize: UInt16 = 16
    
    // Describes the AudioObjectType.  Eg: AAC-LE vs AAC-SBR etc
    var audioObjectType: AudioObjectType
    
    // Enum desribing the sampling rate.  This is used in the ESDS construction.
    // FIXME: Refactor to get integrate the sampleRate variable into this
    var samplingFreq: SamplingFrequency
    
    // ChannelLayout of the stream. Eg: frontCenter vs frontLegAndFrontRight
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



