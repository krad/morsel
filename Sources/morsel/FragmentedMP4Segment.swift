import Foundation
import CoreMedia

class FragmentedMP4Segment {
    
    var file: URL
    var fileHandle: FileHandle
    
    /// Current moof we're on
    var firstSequence: Int
    var currentSequence: Int
    var duration: Double = 0.0
    
    private var config: MOOVConfig
    private var samples: [Sample] = []
    
    
    init(_ file: URL,
         config: MOOVConfig,
         firstSequence: Int) throws
    {
        self.file     = file
        self.config  = config
        
        if !FileManager.default.fileExists(atPath: file.path) {
            FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        }
        
        self.fileHandle      = try FileHandle(forWritingTo: file)
        self.firstSequence   = firstSequence
        self.currentSequence = firstSequence
    }
    
    func write(_ samples: [Sample], with duration: Double) throws {
        self.duration += duration
        
        let moof = MOOF(config: self.config,
                        samples: samples,
                        currentSequence: UInt32(self.currentSequence))
        
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

