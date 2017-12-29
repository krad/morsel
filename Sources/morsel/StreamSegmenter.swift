import Foundation
import Dispatch

public struct AVStreamType: OptionSet {
    public var rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    public static func parse(_ bytes: [UInt8]) -> AVStreamType? {
        guard bytes.count == 2 else { return nil }
        
        if let valueByte = bytes.last {
            guard valueByte >= 0 && valueByte <= 3 else { return nil }
            let streamType = AVStreamType(rawValue: valueByte)
            return streamType
        }
        return nil
    }
    
    public static let video = AVStreamType(rawValue: 1 << 0)
    public static let audio = AVStreamType(rawValue: 1 << 1)
    
    func supported(_ sample: Sample) -> Bool {
        if self == [.video, .audio] { return true }
        if self == [.video] && sample.type == .video { return true }
        if self == [.audio] && sample.type == .audio { return true }
        return false
    }
}

extension AVStreamType: BinaryEncodable { }

protocol StreamSegmenterDelegate {
    func writeInitSegment(with config: MOOVConfig,
                          to url: URL,
                          segmentNumber: Int,
                          isDiscontinuity: Bool)
    
    func createNewSegment(with config: MOOVConfig,
                          to url: URL,
                          segmentNumber: Int,
                          sequenceNumber: Int)
    
    func writeMOOF(with samples: [Sample], duration: Double, sequenceNumber: Int)
}

final internal class StreamSegmenter {
    
    final internal private(set) var outputDir: URL
    final internal let targetSegmentDuration: Double
    final internal var streamType: AVStreamType
    
    final internal var currentSegment  = 0
    final internal var currentSequence = 1
    
    final internal var videoSamples: ThreadSafeArray<Sample>
    final internal var videoSamplesDuration: Double {
        return self.videoSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    final internal var audioSamples: ThreadSafeArray<Sample>
    final internal var audioSamplesDuration: Double {
        return self.audioSamples.reduce(0) { cnt, sample in cnt + sample.durationInSeconds }
    }
    
    final internal var currentSegmentDuration: Double = 0.0

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
                                                to: self.currentSegmentURL,
                                                segmentNumber: self.currentSegment,
                                                isDiscontinuity: true)
                self.signalNewSegment()
            }
        }
    }
    
    internal var audioSettings: AudioSettings? {
        didSet { self.moovConfig.audioSettings = audioSettings }
    }

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
         streamType: AVStreamType = [.video, .audio],
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
        if self.streamType.supported(sample) {
            self.buffer(sample: sample)
            if self.wroteInitSegment {
                self.handle(sample)
            } else {
                if self.readyForMOOV {
                    self.delegate?.writeInitSegment(with: self.moovConfig,
                                                    to: self.currentSegmentURL,
                                                    segmentNumber: self.currentSegment,
                                                    isDiscontinuity: false)
                    self.wroteInitSegment = true
                    self.handle(sample)
                }
            }
        }
    }
    
    private func handle(_ sample: Sample) {
        if self.currentSegment == 0 {
            self.currentSegment += 1
            self.delegate?.createNewSegment(with: self.moovConfig,
                                            to: self.currentSegmentURL,
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
        
        // We're gonna hit our target duration
        if vDuration + self.currentSegmentDuration >= self.targetSegmentDuration {
            
            self.delegate?.writeMOOF(with: vSamples + aSamples,
                                     duration: vDuration,
                                     sequenceNumber: self.currentSequence)
            
            // Bump the sequence and duration
            self.currentSequence        += 1
            self.currentSegmentDuration = vDuration

            // Signal that we should create a new segment
            self.currentSegment += 1
            self.delegate?.createNewSegment(with: self.moovConfig,
                                            to: self.currentSegmentURL,
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
        
        var bufferDuration: Double = 0.0
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
                                        to: self.currentSegmentURL,
                                        segmentNumber: self.currentSegment,
                                        sequenceNumber: self.currentSequence)
    }
    
    private func buffer(sample: Sample) {
        switch sample.type {
        case .audio: self.audioSamples.append(sample)
        case .video: self.videoSamples.append(sample)
        }
    }
    
}
