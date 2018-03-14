import Foundation
import grip

// MARK: - Enum containing errors that can be thrown by the mp4 writer

public enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
    case couldNotAddPlaylist(error: Error)
}

// MARK: - Fragmented MP4 Writer class

/// A class that reads in audio and video samples and produces fragmented mp4's and playlists
public class FragmentedMP4Writer {
    
    var videoDecodeCount: Int64 = 0
    var audioDecodeCount: Int64 = 0
    
    fileprivate var segmenter: StreamSegmenter?
    fileprivate var currentSegment: FragmentedMP4Segment?
    
    private var delegate: FileWriterDelegate?
    private(set) var outputDir: URL
    
    private var representation: Representation
    
// MARK: Setup and Configuration methods
    
    /// Create a new writer
    ///
    /// - Parameters:
    ///   - outputDir: A URL on the local filesystem that playlists and fragmented mp4's should be written to
    ///   - targetDuration: The target duration that each segment should be
    ///   - streamType: Type of stream that is being read.  eg: audio/video, video only, audio only
    ///   - delegate: Delegate that is notified when files are written or updated
    /// - Throws: Will throw errors if any problems with setup arise
    public init(_ outputDir: URL,
                targetDuration: TimeInterval = 6,
                streamType: StreamType = [.video, .audio],
                delegate: FileWriterDelegate? = nil) throws
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
        
        self.delegate = delegate
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
    
// MARK: Adding content to the writer
    
    /// Append a sample for writing
    ///
    /// - Parameters:
    ///   - sample: Sample data that should be written to the stream
    ///   - type: Flag indicating whether the sample is audio or video
    public func append(sample: CompressedSample) {
        switch sample.type {
        case .video: self.append(videoSample: sample)
        case .audio: self.append(audioSample: sample)
        }
    }
    
    private func append(videoSample: CompressedSample) {
        var sample     = videoSample
        sample.decode  = TimeInterval(self.videoDecodeCount)
        
        self.segmenter?.append(sample)
        self.videoDecodeCount += sample.duration
    }
    
    private func append(audioSample: CompressedSample) {
        var sample    = audioSample
        sample.decode = TimeInterval(self.audioDecodeCount)
        
        self.segmenter?.append(sample)
        self.audioDecodeCount += sample.duration
    }

// MARK: Playlist management
    
    public func add(playlist: Playlist) throws {
        do {
            let writer = try PlaylistWriter(baseURL: self.outputDir,
                                            playlist: playlist,
                                            representation: self.representation,
                                            delegate: delegate)
            
            self.representation.add(writer: writer)
        } catch let error {
            throw FragmentedMP4WriterError.couldNotAddPlaylist(error: error)
        }
    }

// MARK: Controlling the state of the writer
    
    /// Appends and end tag for now
    public func stop() {
        self.segmenter?.flush()
        self.representation.end()
    }
    
}

// MARK: - StreamSegmenterDelegate implementation

extension FragmentedMP4Writer: StreamSegmenterDelegate {
    
    func writeInitSegment(with config: MOOVConfig,
                          segmentNumber: Int,
                          isDiscontinuity: Bool)
    {
        let url = self.outputDir.appendingPathComponent("fileSeq\(segmentNumber).mp4")
        do {
            let initSegment = try FragementedMP4InitalizationSegment(url, config: config)
            self.representation.add(segment: initSegment)
        } catch let error {
            print("Could not write init segment #\(segmentNumber) - Error:", error)
        }
        
        self.delegate?.wroteFile(at: url)
    }
    
    func createNewSegment(with config: MOOVConfig,
                          segmentNumber: Int,
                          sequenceNumber: Int)
    {
        if let segment = self.currentSegment {
            self.representation.add(segment: segment)
            self.delegate?.wroteFile(at: segment.url)
        }
        
        let url = self.outputDir.appendingPathComponent("fileSeq\(segmentNumber).mp4")
        self.currentSegment = try? FragmentedMP4Segment(url,
                                                        config: config,
                                                        firstSequence: sequenceNumber)
    }
    
    func writeMOOF(with samples: [CompressedSample], duration: TimeInterval, sequenceNumber: Int) {
        try? self.currentSegment?.write(samples, duration: duration, sequenceNumber: sequenceNumber)
    }
    
}
