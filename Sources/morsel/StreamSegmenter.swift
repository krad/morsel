import Foundation
import Dispatch
import grip

protocol StreamSegmenterDelegate {
    func writeInitSegment(with config: MOOVConfig,
                          segmentNumber: Int,
                          isDiscontinuity: Bool)
    
    func createNewSegment(with config: MOOVConfig,
                          segmentNumber: Int,
                          sequenceNumber: Int)
    
    func writeMOOF(with samples: [CompressedSample], duration: TimeInterval, sequenceNumber: Int)
}

final internal class StreamSegmenter {
    
    final internal let targetSegmentDuration: TimeInterval
    final internal var streamType: StreamType
    
    final internal var currentSegment  = 0
    final internal var currentSequence = 1
    
    final internal var videoSamples: ThreadSafeArray<CompressedSample>
    final internal var videoSamplesDuration: TimeInterval {
        return self.videoSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    final internal var audioSamples: ThreadSafeArray<CompressedSample>
    final internal var audioSamplesDuration: TimeInterval {
        return self.audioSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    final internal var currentSegmentDuration: TimeInterval = 0.0

    private var segmenterQ = DispatchQueue(label: "stream.segmenter.q")
    private var delegate: StreamSegmenterDelegate?
    private var wroteInitSegment: Bool = false

    internal var moovConfig = MOOVConfig()
    internal var videoSettings: VideoSettings? {
        didSet {
            self.moovConfig.videoSettings = videoSettings
            // If we already wrote an init segment we need to write another one
            if self.wroteInitSegment {
                self.writeMOOF() // Flush out remaining samples
                
                self.currentSegment += 1
                self.delegate?.writeInitSegment(with: self.moovConfig,
                                                segmentNumber: self.currentSegment,
                                                isDiscontinuity: true)
                self.signalNewSegment()
            }
        }
    }
    
    internal var audioSettings: AudioSettings? {
        didSet { self.moovConfig.audioSettings = audioSettings }
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

    init(targetSegmentDuration: TimeInterval,
         streamType: StreamType = [.video, .audio],
         delegate: StreamSegmenterDelegate? = nil) throws
    {
        self.targetSegmentDuration = targetSegmentDuration
        self.streamType            = streamType
        self.delegate              = delegate
        self.videoSamples          = ThreadSafeArray<CompressedSample>()
        self.audioSamples          = ThreadSafeArray<CompressedSample>()
    }
    
    func append(_ sample: CompressedSample) {
        if self.streamType.supported(sample) {
            self.buffer(sample: sample)
            if self.wroteInitSegment {
                self.handle(sample)
            } else {
                if self.readyForMOOV {
                    self.delegate?.writeInitSegment(with: self.moovConfig,
                                                    segmentNumber: self.currentSegment,
                                                    isDiscontinuity: false)
                    self.wroteInitSegment = true
                    self.handle(sample)
                }
            }
        }
    }
    
    private func handle(_ sample: CompressedSample) {
        if self.currentSegment == 0 {
            self.currentSegment += 1
            self.delegate?.createNewSegment(with: self.moovConfig,
                                            segmentNumber: self.currentSegment,
                                            sequenceNumber: self.currentSequence)
        } else {
            if sample.isSync { self.writeMOOF() }
        }
    }
    
    private func writeMOOF() {
        let vSamples  = self.vendVideoSamples()
        let vDuration = vSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
        let aSamples  = self.vendAudioSamples(upTo: vDuration)
        
        if (vDuration + self.currentSegmentDuration) >= self.targetSegmentDuration {
            
            self.delegate?.writeMOOF(with: vSamples + aSamples,
                                     duration: vDuration,
                                     sequenceNumber: self.currentSequence)
            
            // Bump the sequence and duration
            self.currentSequence        += 1
            self.currentSegmentDuration = vDuration

            // Signal that we should create a new segment
            self.currentSegment += 1
            self.delegate?.createNewSegment(with: self.moovConfig,
                                            segmentNumber: self.currentSegment,
                                            sequenceNumber: self.currentSequence)
            
        } else {
            // Write another moof
            self.delegate?.writeMOOF(with: vSamples + aSamples,
                                     duration: vDuration,
                                     sequenceNumber: self.currentSequence)
            self.currentSequence        += 1
            self.currentSegmentDuration += vDuration
        }
    }
    
    private func vendVideoSamples() -> [CompressedSample] {
        var results: [CompressedSample] = []

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
    
    private func vendAudioSamples(upTo duration: TimeInterval) -> [CompressedSample] {
        var results: [CompressedSample] = []
        
        var bufferDuration: TimeInterval = 0.0
        for sample in self.audioSamples {
            bufferDuration += sample.durationInSeconds
            results.append(sample)
            if bufferDuration >= duration {
                break
            }
        }
        self.audioSamples.removeFirst(n: results.count)
        return results
    }
    
    private func signalNewSegment() {
        self.currentSegment += 1
        self.delegate?.createNewSegment(with: self.moovConfig,
                                        segmentNumber: self.currentSegment,
                                        sequenceNumber: self.currentSequence)
    }
    
    private func buffer(sample: CompressedSample) {
        switch sample.type {
        case .audio: self.audioSamples.append(sample)
        case .video: self.videoSamples.append(sample)
        default: _=0
        }
    }
    
    internal func flush() {
        while videoSamples.count > 0 { self.writeMOOF() }
        self.signalNewSegment()
    }
    
}
