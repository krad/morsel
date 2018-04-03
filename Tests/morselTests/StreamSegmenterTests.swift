import XCTest
import Foundation
@testable import morsel
import grip

let keyframePayload: [UInt8] = [PacketType.video.rawValue, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10]
let pframePayload: [UInt8]   = [PacketType.video.rawValue, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10]

let landscape = VideoDimensions(from: [0x71, 0, 0, 2, 128, 0, 0, 1, 224])
let portrait  = VideoDimensions(from: [0x71, 0, 0, 1, 224, 0, 0, 2, 128])

class StreamSegmenterTests: XCTestCase {
    
    var iFrame = VideoSample(duration: 1, timescale: 2, data: keyframePayload)
    var pFrame = VideoSample(duration: 1, timescale: 2, data: pframePayload)
    var videoSettings = VideoSettings(params: [[0], [1]],
                                      dimensions: landscape,
                                      timescale: 10)
    
    class MockDelegate: StreamSegmenterDelegate {
        
        var initExp: XCTestExpectation?
        var newSegExp: XCTestExpectation?
        var moofExp: XCTestExpectation?

        var initSegNum: Int = 0
        var discont: Bool = false
        
        var newSegNum: Int = 0
        var newSegSeqNum: Int = 0
        
        var moofSeqNum: Int = 0
        var moofSamples: [VideoSample] = []
        
        func writeInitSegment(with config: MOOVConfig,
                              segmentNumber: Int,
                              isDiscontinuity: Bool)
        {
            self.initSegNum = segmentNumber
            self.discont    = isDiscontinuity
            self.initExp?.fulfill()
        }
        
        func createNewSegment(with config: MOOVConfig,
                              segmentNumber: Int,
                              sequenceNumber: Int)
        {
            self.newSegNum    = segmentNumber
            self.newSegSeqNum = sequenceNumber
            self.newSegExp?.fulfill()
        }

        func writeMOOF(with samples: [CompressedSample], duration: TimeInterval, sequenceNumber: Int) {
            self.moofSeqNum  = sequenceNumber
            self.moofSamples = samples as! [VideoSample]
            self.moofExp?.fulfill()
        }
    }
    
    override func setUp() {
        super.setUp()
        iFrame.isSync = true
        pFrame.isSync = false
        self.continueAfterFailure = false
    }
    
    func test_a_video_only_session() {
        
        let delegate = MockDelegate()
        let subject  = try? StreamSegmenter(targetSegmentDuration: 10.0,
                                            streamType: [.video],
                                            delegate: delegate)
        XCTAssertNotNil(subject)
        
        /// Init segment signaled by video settings and initial keyframe
        delegate.initExp    = self.expectation(description: "Ensure we write an init segment")
        delegate.newSegExp  = self.expectation(description: "Signal a new segment")
        
        // Make sure we're not ready to start writing
        XCTAssertFalse(subject!.readyForMOOV)
        
        // Ok, we should be able to start writing
        subject?.moovConfig.videoSettings = videoSettings
        XCTAssertTrue(subject!.readyForMOOV)
        
        // Appending first iFrame should produce an init segment
        subject?.append(iFrame)
        self.wait(for: [delegate.initExp!, delegate.newSegExp!], timeout: 1)
        XCTAssertEqual(delegate.initSegNum,   0)
        XCTAssertEqual(delegate.newSegNum,    1)
        XCTAssertEqual(delegate.newSegSeqNum, 1)
        XCTAssertFalse(delegate.discont)
        
        /// MOOF signaled by adding a keyframe
        delegate.moofExp = self.expectation(description: "Signal we should write a moof")
        (0..<3).forEach { _ in subject?.append(pFrame) }
        subject?.append(iFrame)
        self.wait(for: [delegate.moofExp!], timeout: 1)
        XCTAssertEqual(delegate.newSegNum,  1)
        XCTAssertEqual(delegate.moofSeqNum, 1)
        
        /// MOOF signaled again (ensure next sequence)
        delegate.moofExp = self.expectation(description: "Signal next moof")
        (0..<3).forEach { _ in subject?.append(pFrame) }
        subject?.append(iFrame)
        subject?.append(pFrame)
        self.wait(for: [delegate.moofExp!], timeout: 1)
        XCTAssertEqual(delegate.newSegNum,  1)
        XCTAssertEqual(delegate.moofSeqNum, 2)
        
        /// Discontinuity signaled by change to video settings
        delegate.moofExp    = self.expectation(description: "Flush whatever we got")
        delegate.initExp    = self.expectation(description: "Signal discontinuity")
        delegate.newSegExp  = self.expectation(description: "Signal a new segment")
        subject?.videoSettings = VideoSettings(params: [[0], [0]], dimensions: portrait, timescale: 10)
        self.wait(for: [delegate.moofExp!, delegate.initExp!, delegate.newSegExp!], timeout: 1)
        XCTAssertTrue(delegate.discont)
        XCTAssertEqual(delegate.initSegNum, 2)
        XCTAssertEqual(delegate.newSegNum,  3)
        XCTAssertEqual(delegate.moofSeqNum, 3)
        
        XCTAssertEqual(2, delegate.moofSamples.count)
        
    }
    
}
