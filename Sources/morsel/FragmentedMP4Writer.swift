import Foundation

public enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

public protocol FragmentedMP4WriterDelegate {
    func wroteFile(at url: URL)
    func updatedFile(at url: URL)
}

public class FragmentedMP4Writer {
    
    var segmenter: StreamSegmenter?
    var currentSegment: FragmentedMP4Segment?
    fileprivate var playerListWriter: HLSPlaylistWriter
    
    var videoDecodeCount: Int64 = 0
    var audioDecodeCount: Int64 = 0
    
    private var delegate: FragmentedMP4WriterDelegate?
    
    public init(_ outputDir: URL,
                targetDuration: Double = 6,
                playlistType: HLSPlaylistType = .live,
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
        
        self.playerListWriter = try HLSPlaylistWriter(outputDir.appendingPathComponent("out.m3u8"),
                                                      playlistType: playlistType,
                                                      targetDuration: targetDuration)
        
        self.segmenter  = try StreamSegmenter(outputDir: outputDir,
                                              targetSegmentDuration: targetDuration,
                                              streamType: streamType,
                                              delegate: self)
        
        self.delegate = delegate
    }
    
    public func configure(settings: VideoSettings) {
        self.segmenter?.videoSettings = settings
    }
    
    public func configure(settings: AudioSettings) {
        self.segmenter?.audioSettings = settings
    }
    
    public func append(sample: Sample, type: AVSampleType) {
        switch type {
        case .video: self.append(videoSample: sample)
        case .audio: self.append(audioSample: sample)
        }
    }
    
    /// Appends and end tag for now
    public func stop() {
        self.playerListWriter.end()
        self.delegate?.updatedFile(at: self.playerListWriter.file)
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
                          to url: URL,
                          segmentNumber: Int,
                          isDiscontinuity: Bool)
    {
        _ = try? FragementedMP4InitalizationSegment(url, config: config)
        
        if isDiscontinuity { self.playerListWriter.writeDiscontinuity(with: segmentNumber) }
        else               { self.playerListWriter.writerHeader() }
        
        self.delegate?.wroteFile(at: self.segmenter!.currentSegmentURL)
    }
    
    func createNewSegment(with config: MOOVConfig,
                          to url: URL,
                          segmentNumber: Int,
                          sequenceNumber: Int)
    {
        if let segment = self.currentSegment {
            self.playerListWriter.write(segment: segment)
            self.delegate?.wroteFile(at: segment.file)
            self.delegate?.updatedFile(at: self.playerListWriter.file)
        }
        
        self.currentSegment = try? FragmentedMP4Segment(url,
                                                        config: config,
                                                        firstSequence: sequenceNumber)
    }
    
    func writeMOOF(with samples: [Sample], duration: Double, sequenceNumber: Int) {
        try? self.currentSegment?.write(samples, duration: duration, sequenceNumber: sequenceNumber)
    }
    
}

