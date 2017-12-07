import Foundation
import CoreMedia

class HLSPlaylistWriter {
    
    var file: URL
    var fileHandle: FileHandle
    var playlistType: HLSPlaylistType
    var contentGenerator: PlaylistWriter
    var targetDuration: Double
    
    init(_ file: URL, playlistType: HLSPlaylistType = .vod, targetDuration: Double) throws {
        self.file         = file
        self.playlistType = playlistType
        
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        
        self.targetDuration = targetDuration
        
        self.fileHandle    = try FileHandle(forWritingTo: file)
        self.fileHandle.truncateFile(atOffset: 0)
        
        switch playlistType {
        case .live:  self.contentGenerator = HLSLivePlayerWriter(numberOfSegments: 3)
        case .event: self.contentGenerator = HLSEventPlaylist()
        case .vod:   self.contentGenerator = HLSVODPlaylist()
        }
    }
    
    func writerHeader() {
        self.write(self.contentGenerator.header(with: self.targetDuration))
    }
    
    func write(segment: FragmentedMP4Segment) {
        if let name = segment.file.path.components(separatedBy: "/").last {
            self.writeSegment(name: name,
                              duration: segment.duration,
                              mediaSequence: segment.firstSequence)
        }
    }
    
    internal func writeSegment(name: String, duration: Double, mediaSequence: Int) {
        if let truncatePosition = contentGenerator.positionToSeek() {
            self.fileHandle.truncateFile(atOffset: truncatePosition)
        }
        self.write(contentGenerator.writeSegment(with: name,
                                                 duration: duration,
                                                 and: mediaSequence))
    }
    
    private func write(_ string: String) {
        let payloadBytes: [UInt8] = Array(string.utf8)
        let data                  = Data(payloadBytes)
        self.fileHandle.write(data)
    }
    
    func end() {
        self.write(contentGenerator.end())
        self.fileHandle.closeFile()
    }

}
