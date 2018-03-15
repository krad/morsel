import XCTest
@testable import morsel
import grip

struct DummySegment: Segment {
    var url: URL
    var duration: TimeInterval
    var isIndex: Bool = false
    var firstMediaSequenceNumber: Int
}

class RepresentationTests: XCTestCase {

    func test_basic_object_behavior() {
        
        let representation = mockRepresentation()
        let settings       = mockVideoSettings()
        representation.videoSettings = settings
        
        XCTAssertNotNil(representation)
        XCTAssertEqual("avc1.42001E", representation.videoSettings?.codec)
        XCTAssertEqual(640, representation.videoSettings?.width)
        XCTAssertEqual(480, representation.videoSettings?.height)
        
        XCTAssertEqual(0, representation.duration)
        XCTAssertEqual(0, representation.segments.count)
        
        addDummySegments(to: representation, count: 10)
    
        XCTAssertEqual(10, representation.segments.count)
        XCTAssertEqual(10_000, representation.duration)
    }
    
    func test_adding_playlists() {
        
        let representation = mockRepresentation()
        let baseURL        = URL(fileURLWithPath: NSTemporaryDirectory())
        
        let vod_playlist    = Playlist(type: .hls_vod, fileName: UUID().uuidString)
        let vodWriter       = try? PlaylistWriter(baseURL: baseURL,
                                                  playlist: vod_playlist,
                                                  representation: representation)

        let event_playlist  = Playlist(type: .hls_event, fileName: UUID().uuidString)
        let eventWriter     = try? PlaylistWriter(baseURL: baseURL,
                                                  playlist: event_playlist,
                                                  representation: representation)
        
        XCTAssertNotNil(vodWriter)
        XCTAssertNotNil(eventWriter)
        
        representation.add(writer: vodWriter!)
        representation.add(writer: eventWriter!)
        
        /// Read the contents first
        var fileContents = readFile(at: vodWriter!.playlistURL)
        XCTAssertEqual("", fileContents)
        
        fileContents = readFile(at: eventWriter!.playlistURL)
        XCTAssertEqual("", fileContents)
        
        /// Now add some dummy segments
        addDummySegments(to: representation, count: 3)

        /// Ensure the contents got updates
        let e1 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-ALLOW-CACHE:YES
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:VOD
#EXT-X-INDEPENDENT-SEGMENTS
#EXTINF:1000.0,
fileSeq0.mp4
#EXTINF:1000.0,
fileSeq1.mp4
#EXTINF:1000.0,
fileSeq2.mp4
#EXT-X-ENDLIST

"""
        
        fileContents = readFile(at: vodWriter!.playlistURL)
        XCTAssertEqual(e1, fileContents)
        
        let e2 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXTINF:1000.0,
fileSeq0.mp4
#EXTINF:1000.0,
fileSeq1.mp4
#EXTINF:1000.0,
fileSeq2.mp4
"""
        
        fileContents = readFile(at: eventWriter!.playlistURL)
        XCTAssertEqual(e2, fileContents)


    }
    
}

func mockVideoSettings() -> VideoSettings {
    let sps: [UInt8] = [66, 0, 30, 137, 139, 96, 80, 30, 216,
                        8, 96, 96, 0, 187, 128, 0, 46, 224, 189,
                        239, 131, 225, 16, 141, 192]
    
    let pps: [UInt8] = [40, 206, 31, 32]
    
    let packet: [UInt8] = [113, 0, 0, 2, 128, 0, 0, 1, 224]
    let dimensions = VideoDimensions(from: packet)
    let settings   = VideoSettings(params: [sps, pps], dimensions: dimensions, timescale: 30000)

    return settings
}

func mockRepresentation() -> Representation {
    let representation = Representation(name: "testRep",
                                        targetDuration: 5.0)
    return representation
}

func addDummySegments(to representation: Representation, count: Int) {
    for i in 0..<count {
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fileSeq\(i).mp4")
        
        let segment = DummySegment(url: url,
                                   duration: 1000,
                                   isIndex: false,
                                   firstMediaSequenceNumber: i)
        representation.add(segment: segment)
    }
}

func mockRepresentationFilled() -> Representation {
    let representation = mockRepresentation()
    addDummySegments(to: representation, count: 10)
    return representation
}
