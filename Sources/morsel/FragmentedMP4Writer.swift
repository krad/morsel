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
    
    public func append(sample: Sample) {
        var videoSample     = sample
        videoSample.decode  = Double(self.videoDecodeCount)
        
        self.segmenter?.append(videoSample)
        self.videoDecodeCount += videoSample.duration
    }
    
    /// Appends and end tag for now
    public func stop() {
        self.playerListWriter.end()
        self.delegate?.updatedFile(at: self.playerListWriter.file)
    }

}

extension FragmentedMP4Writer: StreamSegmenterDelegate {
    func writeInitSegment(with config: MOOVConfig) {
        _ = try? FragementedMP4InitalizationSegment(self.segmenter!.currentSegmentURL,
                                                    config: config)
        
        self.playerListWriter.writerHeader()
        self.delegate?.wroteFile(at: self.segmenter!.currentSegmentURL)
    }
    
    func createNewSegment(with segmentID: Int, and sequenceNumber: Int) {
        if let segment = self.currentSegment {
            self.playerListWriter.write(segment: segment)
            self.delegate?.wroteFile(at: segment.file)
            self.delegate?.updatedFile(at: self.playerListWriter.file)
        }
        
        self.currentSegment = try? FragmentedMP4Segment(self.segmenter!.currentSegmentURL,
                                                        config: self.segmenter!.moovConfig,
                                                        firstSequence: self.segmenter!.currentSequence)
    }
    
    func writeMOOF(with samples: [Sample], and duration: Double) {
        self.currentSegment?.currentSequence = self.segmenter!.currentSequence
        try? self.currentSegment?.write(samples, with: duration)
    }
}

