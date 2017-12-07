import Foundation
import CoreMedia

class FragementedMP4InitalizationSegment {
    
    init(_ file: URL, config: MOOVConfig) throws {
        let ftypBytes = try BinaryEncoder.encode(FTYP())
        let moovBytes = try BinaryEncoder.encode(MOOV(config))
        
        let data = Data(bytes: ftypBytes + moovBytes)
        try data.write(to: file)
    }
}
