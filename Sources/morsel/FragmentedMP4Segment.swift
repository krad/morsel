import Foundation


internal class FragmentedMP4Segment: Segment {
    
    var url: URL
    var fileHandle: FileHandle
    var isIndex: Bool = false
    
    /// Current moof we're on
    var firstMediaSequenceNumber: Int
    var duration: TimeInterval = 0.0
    
    private var config: MOOVConfig
    
    init(_ file: URL,
         config: MOOVConfig,
         firstSequence: Int) throws
    {
        self.url     = file
        self.config  = config
        
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        
        self.fileHandle                 = try FileHandle(forWritingTo: file)
        self.firstMediaSequenceNumber   = firstSequence
    }
    
    func write(_ samples: [Sample], duration: TimeInterval, sequenceNumber: Int) throws {
        self.duration += duration
        
        let moof = MOOF(config: self.config,
                        samples: samples,
                        currentSequence: UInt32(sequenceNumber))
        
        let mdat = MDAT(samples: samples)
        
        let moofBytes = try BinaryEncoder.encode(moof)
        let mdatBytes = try BinaryEncoder.encode(mdat)
        
        let data = Data(bytes: moofBytes + mdatBytes)
        self.fileHandle.write(data)        
    }
    
    deinit {
        self.fileHandle.closeFile()
    }
    
}

