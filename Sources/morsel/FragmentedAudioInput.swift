import CoreMedia

class FragmentedAudioInput {
    
    var onChunk: (AudioSample) -> Void
    var decodeCount: Int64 = 0
    
    init(_ onChunk: @escaping (AudioSample) -> Void) throws {
        self.onChunk = onChunk
    }
    
    func append(_ sample: CMSampleBuffer) {
        let duration         = CMSampleBufferGetDuration(sample)
        
        var audioSample      = AudioSample(sampleBuffer: sample)
        audioSample.duration = duration.value
        audioSample.decode   = Double(decodeCount)

        decodeCount          += duration.value
        
        self.onChunk(audioSample)
    }
    
}
