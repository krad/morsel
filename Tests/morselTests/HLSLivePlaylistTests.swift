import XCTest
@testable import morsel

class HLSLivePlaylistTests: XCTestCase {

    func test_that_we_can_generate_a_live_playlist() {
        
        let representation      = mockRepresentation()
        let playlist            = HLSLivePlaylist(fileName: "live.m3u8")
        playlist.representation = representation
        
        XCTAssertEqual("", playlist.output)

        let baseURL        = URL(fileURLWithPath: NSTemporaryDirectory())
        let initSegmentURL = baseURL.appendingPathComponent("fileSeq0.mp4")
        let initSegment    = DummySegment(url: initSegmentURL, duration: 0, isIndex: true)
        representation.add(segment: initSegment)
        
        let e1 =
        """
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:LIVE
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
"""
        XCTAssertEqual(e1, playlist.output)

        for i in 1...3 {
            let file = baseURL.appendingPathComponent("fileSeq\(i).mp4")
            let segment = DummySegment(url: file, duration: 5.0, isIndex: false)
            representation.add(segment: segment)
        }

        let e2 =
        """
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:LIVE
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq1.mp4
#EXTINF:5.0,
fileSeq2.mp4
#EXTINF:5.0,
fileSeq3.mp4
"""
        XCTAssertEqual(e2, playlist.output)

        let file4       = baseURL.appendingPathComponent("fileSeq4.mp4")
        let segment4    = DummySegment(url: file4, duration: 5.0, isIndex: false)
        representation.add(segment: segment4)

        let e3 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:LIVE
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq2.mp4
#EXTINF:5.0,
fileSeq3.mp4
#EXTINF:5.0,
fileSeq4.mp4
"""
        XCTAssertEqual(e3, playlist.output)

        for i in 5...6  {
            let file = baseURL.appendingPathComponent("fileSeq\(i).mp4")
            let segment = DummySegment(url: file, duration: 5.0, isIndex: false)
            representation.add(segment: segment)
        }
        
        let e4 =
        """
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:LIVE
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq4.mp4
#EXTINF:5.0,
fileSeq5.mp4
#EXTINF:5.0,
fileSeq6.mp4
"""
        XCTAssertEqual(e4, playlist.output)

        let discont2    = baseURL.appendingPathComponent("fileSeq7.mp4")
        let discontSeg2 = DummySegment(url: discont2, duration: 0, isIndex: true)
        representation.add(segment: discontSeg2)
        
        let file8       = baseURL.appendingPathComponent("fileSeq8.mp4")
        let segment8    = DummySegment(url: file8, duration: 5.0, isIndex: false)
        representation.add(segment: segment8)
        
        let e5 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:LIVE
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq6.mp4
#EXT-X-DISCONTINUITY
#EXT-X-MAP-URI="fileSeq7.mp4"
#EXTINF:5.0,
fileSeq8.mp4
"""
        XCTAssertEqual(e5, playlist.output)
        
        let file9       = baseURL.appendingPathComponent("fileSeq9.mp4")
        let segment9    = DummySegment(url: file9, duration: 5.0, isIndex: false)
        representation.add(segment: segment9)

        let e6 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:LIVE
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq7.mp4"
#EXTINF:5.0,
fileSeq8.mp4
#EXTINF:5.0,
fileSeq9.mp4
"""
        XCTAssertEqual(e6, playlist.output)

        
    }
    
}
