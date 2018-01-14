import XCTest
@testable import morsel

class DashVODPlaylistTests: XCTestCase {

    func test_that_we_can_generate_a_dash_playlist() {
        let playlist = DashVODPlaylist()
        playlist.show()
    }
    
}
