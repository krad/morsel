import XCTest
@testable import morsel

struct DummySegment: Segment {
    var url: URL
    var duration: Double
    var isIndex: Bool = false
}

class RepresentationTests: XCTestCase {

    func test_basic_object_behavior() {
        let representation = mockRepresentation()
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
    
}

func mockRepresentation() -> Representation {
    let sps: [UInt8] = [66, 0, 30, 137, 139, 96, 80, 30, 216,
                        8, 96, 96, 0, 187, 128, 0, 46, 224, 189,
                        239, 131, 225, 16, 141, 192]
    
    let pps: [UInt8] = [40, 206, 31, 32]
    
    let dimensions = VideoDimensions(width: 640, height: 480)
    let settings   = VideoSettings(params: [sps, pps], dimensions: dimensions, timescale: 30000)
    
    let representation = Representation(name: "testRep", videoSettings: settings)

    return representation
}

func addDummySegments(to representation: Representation, count: Int) {
    for _ in 0..<count {
        let segment = DummySegment(url: URL(fileURLWithPath: NSTemporaryDirectory()),
                                   duration: 1000,
                                   isIndex: false)
        representation.add(segment: segment)
    }
}
