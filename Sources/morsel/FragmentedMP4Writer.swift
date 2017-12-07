import Foundation
import AVFoundation

public enum FragmentedMP4WriterError: Error {
    case fileNotDirectory
    case directoryDoesNotExist
}

public class FragmentedMP4Writer {
    
    var segmenter: StreamSegmenter?
    var videoInput: FragmentedVideoInput?
    var audioInput: FragmentedAudioInput?
    var currentSegment: FragmentedMP4Segment?
    fileprivate var playerListWriter: HLSPlaylistWriter
    
    public init(_ outputDir: URL,
                targetDuration: Double = 6,
                playlistType: HLSPlaylistType = .live,
                streamType: StreamType = [.video, .audio]) throws
    {
        /// Verify we have a directory to write to
        var isDir: ObjCBool = false
        let pathExists      = FileManager.default.fileExists(atPath: outputDir.path, isDirectory: &isDir)
        if !isDir.boolValue { throw FragmentedMP4WriterError.fileNotDirectory }
        if !pathExists      { throw FragmentedMP4WriterError.directoryDoesNotExist }
        
        self.playerListWriter = try HLSPlaylistWriter(outputDir.appendingPathComponent("out.m3u8"),
                                                      playlistType: playlistType,
                                                      targetDuration: targetDuration)
        
        self.segmenter  = try StreamSegmenter(outputDir: outputDir,
                                              targetSegmentDuration: targetDuration,
                                              streamType: streamType,
                                              delegate: self)
        
        self.videoInput = try FragmentedVideoInput() { sample in
            self.segmenter?.append(sample)
        }
        
        self.audioInput = try FragmentedAudioInput() { sample in
            self.segmenter?.append(sample)
        }
    }
    
    public func got(_ sample: CMSampleBuffer, type: SampleType) {
        switch type {
        case .video: self.videoInput?.append(sample)
        case .audio: self.audioInput?.append(sample)
        }
    }
    
    public func end() {
        self.playerListWriter.end()
    }
    
    func stop() {
        self.playerListWriter.end()
    }

}

extension FragmentedMP4Writer: StreamSegmenterDelegate {
    func writeInitSegment(with config: MOOVConfig) {
        _ = try? FragementedMP4InitalizationSegment(self.segmenter!.currentSegmentURL,
                                                    config: config)
        
        self.playerListWriter.writerHeader()
    }
    
    func createNewSegment(with segmentID: Int, and sequenceNumber: Int) {
        if let segment = self.currentSegment {
            self.playerListWriter.write(segment: segment)
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

