import Foundation

public enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

public protocol FragmentedMP4WriterDelegate {
    func wroteFile(at url: URL)
    func updatedFile(at url: URL)
}


/// A class that reads in audio and video samples and produces fragmented mp4's and playlists
public class FragmentedMP4Writer {
    
    var videoDecodeCount: Int64 = 0
    var audioDecodeCount: Int64 = 0
    
    fileprivate var segmenter: StreamSegmenter?
    fileprivate var currentSegment: FragmentedMP4Segment?
    
    private var delegate: FragmentedMP4WriterDelegate?
    private(set) var outputDir: URL
    
    private var representation: Representation

    
    /// Create a new writer
    ///
    /// - Parameters:
    ///   - outputDir: A URL on the local filesystem that playlists and fragmented mp4's should be written to
    ///   - targetDuration: The target duration that each segment should be
    ///   - playlistType: Playlist type the writer should produce
    ///   - streamType: Type of stream that is being read.  eg: audio/video, video only, audio only
    ///   - delegate: Delegate that is notified when files are written or updated
    /// - Throws: Will throw errors if any problems with setup arise
    public init(_ outputDir: URL,
                targetDuration: Double = 6,
                streamType: AVStreamType = [.video, .audio],
                delegate: FragmentedMP4WriterDelegate? = nil) throws
    {
        /// Verify we have a directory to write to
        var isDir: ObjCBool = false
        let pathExists      = FileManager.default.fileExists(atPath: outputDir.path, isDirectory: &isDir)
        if !pathExists { throw FragmentedMP4WriterError.directoryDoesNotExist }
        #if os(Linux)
            if !isDir { throw FragmentedMP4WriterError.fileNotDirectory }
        #else
            if !isDir.boolValue { throw FragmentedMP4WriterError.fileNotDirectory }
        #endif
        
        self.outputDir      = outputDir
        self.representation = Representation(name: "base",
                                             targetDuration: targetDuration)
        
        self.segmenter      = try StreamSegmenter(targetSegmentDuration: targetDuration,
                                                  streamType: streamType,
                                                  delegate: self)
        
        self.delegate       = delegate
    }
    
    
    /// Configure the writer with video settings.
    /// This happens after initial setup because a video source might not be known / available
    ///
    /// - Parameter settings: VideoSettings struct describing video portion of the stream
    public func configure(settings: VideoSettings) {
        self.segmenter?.videoSettings = settings
    }
    
    
    /// Configure the writer with audio settings
    /// This happens after initial setup because an audio source might not be known / available
    ///
    /// - Parameter settings: AudioSettings struct describing the audio portion of the stream
    public func configure(settings: AudioSettings) {
        self.segmenter?.audioSettings = settings
    }
    
    
    /// Append a sample for writing
    ///
    /// - Parameters:
    ///   - sample: Sample data that should be written to the stream
    ///   - type: Flag indicating whether the sample is audio or video
    public func append(sample: Sample, type: AVSampleType) {
        switch type {
        case .video: self.append(videoSample: sample)
        case .audio: self.append(audioSample: sample)
        }
    }
    
    /// Appends and end tag for now
    public func stop() {
//        self.playerListWriter.end()
//        self.delegate?.updatedFile(at: self.playerListWriter.file)
    }
    
    private func append(videoSample: Sample) {
        var sample     = videoSample
        sample.decode  = Double(self.videoDecodeCount)
        
        self.segmenter?.append(sample)
        self.videoDecodeCount += sample.duration
    }
    
    private func append(audioSample: Sample) {
        var sample    = audioSample
        sample.decode = Double(self.audioDecodeCount)
        
        self.segmenter?.append(sample)
        self.audioDecodeCount += sample.duration
    }

}

extension FragmentedMP4Writer: StreamSegmenterDelegate {
    
    func writeInitSegment(with config: MOOVConfig,
                          segmentNumber: Int,
                          isDiscontinuity: Bool)
    {
        let url = self.outputDir.appendingPathComponent("fileSeq\(segmentNumber).mp4")
        _ = try? FragementedMP4InitalizationSegment(url, config: config)
        
//        if isDiscontinuity { self.playerListWriter.writeDiscontinuity(with: segmentNumber) }
//        else               { self.playerListWriter.writerHeader() }
        
        self.delegate?.wroteFile(at: url)
    }
    
    func createNewSegment(with config: MOOVConfig,
                          segmentNumber: Int,
                          sequenceNumber: Int)
    {
        if let segment = self.currentSegment {
//            self.playerListWriter.write(segment: segment)
            self.delegate?.wroteFile(at: segment.file)
//            self.delegate?.updatedFile(at: self.playerListWriter.file)
        }
        
        let url = self.outputDir.appendingPathComponent("fileSeq\(segmentNumber).mp4")
        self.currentSegment = try? FragmentedMP4Segment(url,
                                                        config: config,
                                                        firstSequence: sequenceNumber)
    }
    
    func writeMOOF(with samples: [Sample], duration: Double, sequenceNumber: Int) {
        try? self.currentSegment?.write(samples, duration: duration, sequenceNumber: sequenceNumber)
    }
    
}
