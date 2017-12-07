import CoreMedia

class FragmentedVideoInput {
    
    var settings = VideoEncoderSettings()
    var videoEncoder: VideoEncoder?
    var onChunk: (VideoSample) -> Void
    
    var decodeCount: Int64 = 0
    
    init(_ onChunk: @escaping (VideoSample) -> Void) throws {
        self.onChunk = onChunk
        self.settings.allowFrameReordering        = false
        self.settings.profileLevel                = .h264High_4_0
        self.settings.maxKeyFrameIntervalDuration = 1
        self.videoEncoder = try VideoEncoder(settings, delegate: self)
    }
    
    func append(_ sample: CMSampleBuffer) {
        self.videoEncoder?.encode(sample)
    }
    
}

extension FragmentedVideoInput: VideoEncoderDelegate {
    func encoded(videoSample: CMSampleBuffer) {
        
        let duration           = CMSampleBufferGetDuration(videoSample)
        
        var sample             = VideoSample(sampleBuffer: videoSample)
        sample.timescale       = UInt32(duration.timescale)
        sample.durationSeconds = Double(duration.value) / Double(duration.timescale)
        sample.duration        = duration.value
        sample.decode          = Double(decodeCount)

        decodeCount            += duration.value

        
        self.onChunk(sample)
    }
}
