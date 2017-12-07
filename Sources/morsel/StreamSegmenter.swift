import Foundation
import CoreMedia

public struct StreamType: OptionSet {
    public var rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public static let video = StreamType(rawValue: 1 << 0)
    public static let audio = StreamType(rawValue: 1 << 1)
    
    func supported(_ sample: Sample) -> Bool {
        if self == [.video, .audio] { return true }
        if self == [.video] && sample.type == .video { return true }
        if self == [.audio] && sample.type == .audio { return true }
        return false
    }
    
}

protocol StreamSegmenterDelegate {
    func writeInitSegment(with config: MOOVConfig)
    func createNewSegment(with segmentID: Int, and sequenceNumber: Int)
    func writeMOOF(with samples: [Sample], and duration: Double)
}

class StreamSegmenter {
    
    var outputDir: URL
    let targetSegmentDuration: Double
    var streamType: StreamType
    
    var currentSegment  = 0
    var currentSequence = 1
    
    internal var videoSamples: ThreadSafeArray<Sample>
    internal var videoSamplesDuration: Double {
        return self.videoSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    internal var audioSamples: ThreadSafeArray<Sample>
    internal var audioSamplesDuration: Double {
        return self.audioSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    internal var currentSegmentDuration: Double = 0.0
    

    private var segmenterQ = DispatchQueue(label: "stream.segmenter.Q")
    internal var moovConfig = MOOVConfig()
    private var delegate: StreamSegmenterDelegate?
    private var wroteInitSegment: Bool = false

    var currentSegmentName: String {
        return "fileSeq\(self.currentSegment).mp4"
    }
    
    var currentSegmentURL: URL {
        return self.outputDir.appendingPathComponent(self.currentSegmentName)
    }
    
    internal var readyForMOOV: Bool {
        if self.streamType == [.video, .audio] {
            let presence: [Any?] = [moovConfig.videoSettings, moovConfig.audioSettings].filter { $0 != nil }
            if presence.count == 2 { return true }
        }

        if self.streamType == [.video] {
            let presence: [Any?] = [moovConfig.videoSettings].filter { $0 != nil }
            if presence.count != 0 { return true }
        }

        if self.streamType == [.audio] {
            let presence: [Any?] = [moovConfig.audioSettings].filter { $0 != nil }
            if presence.count != 0 { return true }
        }

        return false
    }

    init(outputDir: URL,
         targetSegmentDuration: Double,
         streamType: StreamType = [.video, .audio],
         delegate: StreamSegmenterDelegate? = nil) throws
    {
        self.outputDir             = outputDir
        self.targetSegmentDuration = targetSegmentDuration
        self.streamType            = streamType
        self.delegate              = delegate
        self.videoSamples          = ThreadSafeArray<Sample>()
        self.audioSamples          = ThreadSafeArray<Sample>()
    }
    
    func append(_ sample: Sample) {
        self.updateMOOVConfig(with: sample)
        if self.streamType.supported(sample) {
            
            self.buffer(sample: sample)
            
            if self.wroteInitSegment {
                self.handle(sample)
            } else {
                if self.readyForMOOV {
                    self.delegate?.writeInitSegment(with: self.moovConfig)
                    self.wroteInitSegment = true
                    self.handle(sample)
                }
            }
            
        }
    }
    
    private func handle(_ sample: Sample) {
        if self.currentSegment == 0 {
            self.currentSegment += 1
            self.delegate?.createNewSegment(with: self.currentSegment, and: self.currentSequence)
        } else {
            
            if sample.isSync { self.writeMOOF() }
        }
    }
    
    private func writeMOOF() {
        let vSamples  = self.vendVideoSamples()
        let vDuration = vSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
        let aSamples  = self.vendAudioSamples(upTo: vDuration)
        
        // We're gonna hit our target duration
        if vDuration + self.currentSegmentDuration >= self.targetSegmentDuration {
            self.delegate?.writeMOOF(with: vSamples + aSamples, and: vDuration)
            
            // Bump the sequence and duration
            self.currentSequence        += 1
            self.currentSegmentDuration = vDuration

            // Signal that we should create a new segment
            self.currentSegment += 1
            self.delegate?.createNewSegment(with: self.currentSegment, and: self.currentSequence)
            
        } else {
            // Write another moof
            self.delegate?.writeMOOF(with: vSamples + aSamples, and: vDuration)
            self.currentSequence        += 1
            self.currentSegmentDuration += vDuration
        }
    }
    
    private func vendVideoSamples() -> [Sample] {
        var results: [Sample] = []

        for (i, sample) in self.videoSamples.enumerated() {
            if sample.isSync {
                if i == 0 { results.append(sample) }
                else      { break }
            } else {
                results.append(sample)
            }
        }
        
        self.videoSamples.removeFirst(n: results.count)
        return results
    }
    
    private func vendAudioSamples(upTo duration: Double) -> [Sample] {
        var results: [Sample] = []
        
        for sample in self.audioSamples {
            results.append(sample)
            if results.count > 50 {
                break
            }
        }
        
//        var bufferDuration: Double = 0.0
//        for sample in self.audioSamples {
//            bufferDuration += sample.durationInSeconds
//            results.append(sample)
//            if bufferDuration >= duration {
//                break
//            }
//        }

        self.audioSamples.removeFirst(n: results.count)
        return results
    }
    
    private func signalNewSegment() {
        self.currentSegment += 1
        self.delegate?.createNewSegment(with: self.currentSegment, and: self.currentSequence)
    }
    
    private func buffer(sample: Sample) {
        switch sample.type {
        case .audio: self.audioSamples.append(sample)
        case .video: self.videoSamples.append(sample)
        }
    }

    private func updateMOOVConfig(with sample: Sample) {
        switch sample.type {
        case .audio: self.moovConfig.audioSettings = MOOVAudioSettings(sample)
        case .video: self.moovConfig.videoSettings = MOOVVideoSettings(sample)
        }
    }
    
}
