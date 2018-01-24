import Foundation

enum PlaylistError: Error {
    case couldNotOpenFileForWriting
}

internal class PlaylistWriter {
    
    private let playlist: Playlist
    internal let playlistURL: URL
    internal var generator: PlaylistGenerator
    private let fileHandle: FileHandle
    private var delegate: FileWriterDelegate?
    
    init(baseURL: URL,
         playlist: Playlist,
         representation: Representation,
         delegate: FileWriterDelegate? = nil) throws
    {
        self.playlist    = playlist
        self.playlistURL = baseURL.appendingPathComponent(playlist.fileName)
        
        switch playlist.type {
        case .hls_vod:
            self.generator = HLSVODPlaylist(fileName: playlist.fileName)
        case .hls_event:
            self.generator = HLSEventPlaylist(fileName: playlist.fileName)
        case .hls_live:
            self.generator = HLSLivePlaylist(fileName: playlist.fileName)
        }
        
        if !FileManager.default.fileExists(atPath: self.playlistURL.path) {
            FileManager.default.createFile(atPath: self.playlistURL.path, contents: nil, attributes: nil)
        }
        
        if let fh = FileHandle(forWritingAtPath: self.playlistURL.path) { self.fileHandle = fh }
        else { throw PlaylistError.couldNotOpenFileForWriting }
        
        self.generator.representation = representation
        self.delegate = delegate
    }
    
    func update() {
        if let data = self.generator.output.data(using: .utf8) {
            self.fileHandle.truncateFile(atOffset: 0)
            self.fileHandle.write(data)
            self.delegate?.updatedFile(at: self.playlistURL)
        }
    }
    
    deinit {
        self.fileHandle.closeFile()
    }
        
}
