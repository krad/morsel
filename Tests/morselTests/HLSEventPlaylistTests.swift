import XCTest
@testable import morsel

class HLSEventPlaylistTests: XCTestCase {

    func test_that_we_can_generate_an_event_playlist() {
        
        let representation      = mockRepresentation()
        let playlist            = HLSEventPlaylist(fileName: "event.m3u8")
        playlist.representation = representation
        
let e1 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
"""
        XCTAssertEqual(e1, playlist.output)
        
        let baseURL        = URL(fileURLWithPath: NSTemporaryDirectory())
        let initSegmentURL = baseURL.appendingPathComponent("fileSeq0.mp4")
        let initSegment    = DummySegment(url: initSegmentURL, duration: 0, isIndex: true)
        representation.add(segment: initSegment)

let e2 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP:URI="fileSeq0.mp4"
"""
        XCTAssertEqual(e2, playlist.output)
        
        let file1 = baseURL.appendingPathComponent("fileSeq1.mp4")
        let file1Seg = DummySegment(url: file1, duration: 5.0, isIndex: false)
        representation.add(segment: file1Seg)
        
let e3 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP:URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq1.mp4
"""
        XCTAssertEqual(e3, playlist.output)
        
        let file2 = baseURL.appendingPathComponent("fileSeq2.mp4")
        let file2Seg = DummySegment(url: file2, duration: 5.0, isIndex: true)
        representation.add(segment: file2Seg)

let e4 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP:URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq1.mp4
#EXT-X-DISCONTINUITY
#EXT-X-MAP:URI="fileSeq2.mp4"
"""
        XCTAssertEqual(e4, playlist.output)

        let file3 = baseURL.appendingPathComponent("fileSeq3.mp4")
        let file3Seg = DummySegment(url: file3, duration: 5.3002, isIndex: false)
        representation.add(segment: file3Seg)
        
let e5 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP:URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq1.mp4
#EXT-X-DISCONTINUITY
#EXT-X-MAP:URI="fileSeq2.mp4"
#EXTINF:5.3002,
fileSeq3.mp4
"""
        XCTAssertEqual(e5, playlist.output)
        representation.state = .done

let e6 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP:URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq1.mp4
#EXT-X-DISCONTINUITY
#EXT-X-MAP:URI="fileSeq2.mp4"
#EXTINF:5.3002,
fileSeq3.mp4
#EXT-X-ENDLIST

"""
        XCTAssertEqual(e6, playlist.output)


        
    }
    
}
