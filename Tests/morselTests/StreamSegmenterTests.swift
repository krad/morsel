import XCTest
@testable import morsel

let keyframePayload: [UInt8] = [AVSampleType.video.rawValue, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10]
let pframePayload: [UInt8]   = [AVSampleType.video.rawValue, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10]

let landscape = VideoDimensions(from: [0, 0, 0, 2, 128, 0, 0, 1, 224])
let portrait  = VideoDimensions(from: [0, 0, 0, 1, 224, 0, 0, 2, 128])

class StreamSegmenterTests: XCTestCase {
    
    var iFrame = VideoSample(bytes: keyframePayload)
    var pFrame = VideoSample(bytes: pframePayload)
    var videoSettings = VideoSettings(params: [[0], [1]],
                                      dimensions: landscape,
                                      timescale: 10)
    
    class MockDelegate: StreamSegmenterDelegate {
        
        var initExp: XCTestExpectation?
        var newSegExp: XCTestExpectation?
        var moofExp: XCTestExpectation?

        var initSegNum: Int = 0
        var initSegURL: URL?
        var discont: Bool = false
        
        var newSegNum: Int = 0
        var newSegURL: URL?
        var newSegSeqNum: Int = 0
        
        var moofSeqNum: Int = 0
        var moofSamples: [VideoSample] = []
        
        func writeInitSegment(with config: MOOVConfig,
                              to url: URL,
                              segmentNumber: Int,
                              isDiscontinuity: Bool)
        {
            self.initSegURL = url
            self.initSegNum = segmentNumber
            self.discont    = isDiscontinuity
            self.initExp?.fulfill()
        }
        
        func createNewSegment(with config: MOOVConfig,
                              to url: URL,
                              segmentNumber: Int,
                              sequenceNumber: Int)
        {
            self.newSegURL    = url
            self.newSegNum    = segmentNumber
            self.newSegSeqNum = sequenceNumber
            self.newSegExp?.fulfill()
        }

        func writeMOOF(with samples: [Sample], duration: Double, sequenceNumber: Int) {
            self.moofSeqNum  = sequenceNumber
            self.moofSamples = samples as! [VideoSample]
            self.moofExp?.fulfill()
        }
    }
    
    func test_a_video_only_session() {
        
        if let url = URL(string: NSTemporaryDirectory()) {
        
            let delegate = MockDelegate()
            let subject  = try? StreamSegmenter(outputDir: url,
                                                targetSegmentDuration: 10.0,
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
            XCTAssertEqual(delegate.initSegURL?.path.split(separator: "/").last, "fileSeq0.mp4")
            XCTAssertEqual(delegate.newSegURL?.path.split(separator: "/").last, "fileSeq1.mp4")
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
            XCTAssertEqual(delegate.initSegURL?.path.split(separator: "/").last, "fileSeq2.mp4")
            XCTAssertEqual(delegate.newSegURL?.path.split(separator: "/").last, "fileSeq3.mp4")

            XCTAssertEqual(2, delegate.moofSamples.count)
            
        } else {
            XCTFail("Could not create tmp directory \(#file) \(#line)")
        }
        
    }
    
}
