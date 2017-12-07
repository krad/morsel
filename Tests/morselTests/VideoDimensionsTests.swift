import XCTest
@testable import morsel

class VideoDimensionsTests: XCTestCase {

    func test_that_we_can_create_a_video_dimension_struct_from_network_data() {
        
        let packet: [UInt8] = [113, 0, 0, 2, 128, 0, 0, 1, 224]
        let dimensions      = VideoDimensions(from: packet)
        XCTAssertEqual(640, dimensions.width)
        XCTAssertEqual(480, dimensions.height)
        
    }
    
}
