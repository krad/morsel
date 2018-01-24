import XCTest
@testable import morsel

class PlaylistWriterTests: XCTestCase {

    func test_that_we_can_write_a_playlist_to_a_file() {
        let representation = mockRepresentation()
        let event          = Playlist(type: .hls_event, fileName: UUID().uuidString)
        let baseURL        = URL(fileURLWithPath: NSTemporaryDirectory())
        
        var writer: PlaylistWriter?
        XCTAssertNoThrow(writer = try PlaylistWriter(baseURL: baseURL,
                                                     playlist: event,
                                                     representation: representation))
        XCTAssertNotNil(writer)
        
        var fileContents = readFile(at: writer!.playlistURL)
        XCTAssertEqual("", fileContents)
        
        let initSegmentURL = baseURL.appendingPathComponent("fileSeq0.mp4")
        let initSegment    = DummySegment(url: initSegmentURL, duration: 0, isIndex: true)
        representation.add(segment: initSegment)

        writer?.update()
        
        let e1 =
"""
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
"""
        
        fileContents = readFile(at: writer!.playlistURL)
        XCTAssertEqual(e1, fileContents)
        
        let fileURL1        = baseURL.appendingPathComponent("fileSeq1.mp4")
        let fileSegment1    = DummySegment(url: fileURL1, duration: 5.0, isIndex: false)
        representation.add(segment: fileSegment1)
        
        writer?.update()

        let e2 =
        """
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq1.mp4
"""
        
        fileContents = readFile(at: writer!.playlistURL)
        XCTAssertEqual(e2, fileContents)

        representation.state = .done
        writer?.update()

        let e3 =
        """
#EXTM3U
#EXT-X-TARGETDURATION:5
#EXT-X-VERSION:7
#EXT-X-MEDIA_SEQUENCE:1
#EXT-X-PLAYLIST-TYPE:EVENT
#EXT-X-INDEPENDENT-SEGMENTS
#EXT-X-MAP-URI="fileSeq0.mp4"
#EXTINF:5.0,
fileSeq1.mp4
#EXT-X-ENDLIST

"""
        
        fileContents = readFile(at: writer!.playlistURL)
        XCTAssertEqual(e3, fileContents)

    }
    
}

func readFile(at path: URL) -> String {
    do {
        let data = try Data(contentsOf: path)
        if let dataStr = String(data: data, encoding: .utf8) {
            return dataStr
        }
        return ""
    } catch {
        return ""
    }
}
