// FIXME
import Foundation

struct STSD: BinarySizedEncodable {
    
    let type: Atom = .stsd
    var version: UInt8 = 0
    var flags: [UInt8] = [0, 0, 0]
    
    var numberOfEntries: UInt32 = 1
    
    var avc1: [AVC1]?
    var mp4a: [MP4A]?
    
    static func from(_ config: VideoSettings) -> STSD {
        var stsd = STSD()
        stsd.avc1 = [AVC1.from(config)]
        
        // FIXME: Remove.  This is here to test integration with cisco's bullshit h264 thing
        if let avc1 = stsd.avc1 {
            let avc1Bytes = try? BinaryEncoder.encode(avc1)
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask, true)[0]
            let uuid = UUID().uuidString
            let url  = URL(fileURLWithPath: documentsPath).appendingPathComponent("\(uuid).h264_params")
            let data = Data(avc1Bytes!)
            do {
                print("Writing data to", url)
                try data.write(to: url)
            } catch let err {
                print("Could not write data", err)
            }
        }
        
        stsd.mp4a = nil
        return stsd
    }
    
    static func from(_ config: AudioSettings) -> STSD {
        var stsd    = STSD()
        stsd.avc1   = nil
        stsd.mp4a   = [MP4A.from(config)]
        return stsd
    }
    
}
