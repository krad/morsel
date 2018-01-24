import Foundation

class FragementedMP4InitalizationSegment: Segment {
    
    var url: URL
    var duration: Double = 0.0
    var isIndex: Bool = true
    var firstMediaSequenceNumber: Int = 0
    
    
    init(_ file: URL, config: MOOVConfig) throws {
        self.url      = file
        let ftypBytes = try BinaryEncoder.encode(FTYP())
        let moovBytes = try BinaryEncoder.encode(MOOV(config))
        
        let data = Data(bytes: ftypBytes + moovBytes)
        try data.write(to: file)
    }
}
