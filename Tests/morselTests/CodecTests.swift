import XCTest
@testable import morsel

class CodecTests: XCTestCase {

    func test_that_we_can_parse_video_codec_types_by_rfc6381() {
        
        let rfc = RFC6381.parse("avc1.42001e")
        XCTAssertNotNil(rfc)
        XCTAssertEqual("avc1", rfc?.codec)
        XCTAssertEqual(0x42, rfc?.profile)
        XCTAssertEqual(0, rfc?.constraint)
        XCTAssertEqual(30, rfc?.level)
        
        let c1 = VideoCodec.parse("avc1.42001e")
        XCTAssertNotNil(c1)
        XCTAssertEqual(c1?.name, "avc1.42001E")

        let c2 = VideoCodec.parse("avc1.42001f")
        XCTAssertNotNil(c2)
        XCTAssertEqual(c2?.name, "avc1.42001F")
        
        let c3 = VideoCodec.parse("avc1.4d001f")
        XCTAssertNotNil(c3)
        XCTAssertEqual(c3?.name, "avc1.4D001F")
        
        let c4 = VideoCodec.parse("avc1.4d0029")
        XCTAssertNotNil(c4)
        XCTAssertEqual(c4?.name, "avc1.4D0029")
        
    }
    
}
