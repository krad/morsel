import XCTest
import AEXML
@testable import morsel

class DashVODPlaylistTests: XCTestCase {

    func test_that_we_can_generate_a_dash_playlist() {
        
        let representation      = mockRepresentation()
        let videoSettings       = mockVideoSettings()
        representation.videoSettings = videoSettings
        
        let playlist            = DashVODPlaylist(fileName: "vod.mpd")
        playlist.representation = representation
        XCTAssertEqual("", playlist.output)
        
        let baseURL  = URL(fileURLWithPath: NSTemporaryDirectory())

        let file0    = baseURL.appendingPathComponent("fileSeq0.mp4")
        let segment0 = DummySegment(url: file0, duration: 0, isIndex: true, firstMediaSequenceNumber: 0)
        representation.add(segment: segment0)
        
        let file1    = baseURL.appendingPathComponent("fileSeq1.mp4")
        let segment1 = DummySegment(url: file1, duration: 5.5, isIndex: false, firstMediaSequenceNumber: 1)
        representation.add(segment: segment1)
        
        let e1 =
"""
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<MPD profiles="urn:mpeg:dash:profile:full:2011" maxSegmentDuration="PT6.0S" xmlns="urn:mpeg:dash:schema:mpd:2011" type="static">
    <Period duration="PT5S">
        <AdaptationSet mimeType="video/mp4">
            <Representation bandwidth="80000" height="480" id="base" width="640">
                <SegmentList duration="165000" timescale="30000">
                    <Initialization sourceURL="fileSeq0.mp4" />
                    <SegmentURL media="fileSeq1.mp4" />
                </SegmentList>
            </Representation>
        </AdaptationSet>
    </Period>
</MPD>
"""
        let docE = try? AEXMLDocument(xml: e1)
        let doc  = try? AEXMLDocument(xml: playlist.output)
        XCTAssertNotNil(doc)
        XCTAssertNotNil(docE)
        XCTAssertEqual(docE!.root["Period"].xml, doc!.root["Period"].xml)
        
    }
    
}
