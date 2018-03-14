import XCTest
@testable import morsel
import grip

let sps: [UInt8] = [66, 0, 30, 137, 139, 96, 80, 30, 216,
                    8, 96, 96, 0, 187, 128, 0, 46, 224, 189,
                    239, 131, 225, 16, 141, 192]

let pps: [UInt8] = [40, 206, 31, 32]

class FragmentedMP4WriterTests: XCTestCase {

    var iFrame          = VideoSample(bytes: keyframePayload)
    var pFrame          = VideoSample(bytes: pframePayload)
    var videoSettings   = VideoSettings(params: [sps, pps],
                                        dimensions: landscape,
                                        timescale: 10)

    class MockDelegate: FileWriterDelegate {
        
        var writeExp: XCTestExpectation?
        var updateExp: XCTestExpectation?
        
        var files: [URL] = []
        
        func wroteFile(at url: URL) {
            writeExp?.fulfill()
            self.files.append(url)
        }

        func updatedFile(at url: URL) {
            updateExp?.fulfill()
        }
    }
    
    func test_that_we_flush_buffers_when_we_call_end() {
  
        let outdir   = URL(fileURLWithPath: NSTemporaryDirectory())
        let delegate = MockDelegate()
        let subject  = try? FragmentedMP4Writer(outdir,
                                                targetDuration: 10,
                                                streamType: .video,
                                                delegate: delegate)
        XCTAssertNotNil(subject)
        
        let playlist = Playlist(type: .hls_vod, fileName: "vod.m3u8")
        XCTAssertNoThrow(try subject?.add(playlist: playlist))
        
        delegate.writeExp = self.expectation(description: "We should write a file")
        
        subject?.configure(settings: videoSettings)
        XCTAssertEqual(iFrame.durationInSeconds, 0.5)
        XCTAssertEqual(pFrame.durationInSeconds, 0.5)
        
        subject?.append(sample: iFrame)
        self.wait(for: [delegate.writeExp!], timeout: 2)
        XCTAssertEqual(1, delegate.files.count)

        subject?.append(sample: pFrame)

        subject?.append(sample: iFrame)
        subject?.append(sample: pFrame)

        subject?.append(sample: iFrame)
        subject?.append(sample: pFrame)
        
        delegate.writeExp = self.expectation(description: "We should flush what we have")
        subject?.stop()

        self.wait(for: [delegate.writeExp!], timeout: 1)
        XCTAssertEqual(2, delegate.files.count)
    }
    
}
