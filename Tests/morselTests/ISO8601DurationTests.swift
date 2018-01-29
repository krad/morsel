import XCTest
@testable import morsel

class ISO8601DurationTests: XCTestCase {
    
    func test_that_we_can_pull_number_and_type_information_from_strings() {
        let bigDateStr = "P3Y8M10DT12H43M2S"
        let parsed     = NSDateComponents.parse(bigDateStr)
        XCTAssertEqual(6, parsed.count)
        
        for result in parsed {
            switch result {
            case .years(let value):   XCTAssertEqual(value, 3)
            case .months(let value):  XCTAssertEqual(value, 8)
            case .weeks(_):           XCTFail("We ain't got no weeks.")
            case .days(let value):    XCTAssertEqual(value, 10)
            case .hours(let value):   XCTAssertEqual(value, 12)
            case .minutes(let value): XCTAssertEqual(value, 43)
            case .seconds(let value): XCTAssertEqual(value, 2)
            }
        }
    }
    
    func test_that_we_can_create_date_components_from_a_string() {
        let bigDateStr = "P3Y8M10DT12H43M2S"
        let result     = NSDateComponents.duration(from: bigDateStr)
        XCTAssertEqual(result.year, 3)
        XCTAssertEqual(result.month, 8)
        XCTAssertEqual(result.day, 10)
        XCTAssertEqual(result.hour, 12)
        XCTAssertEqual(result.minute, 43)
        XCTAssertEqual(result.second, 2)
        
        let lilDateStr = "PT5M"
        let result2     = NSDateComponents.duration(from: lilDateStr)
        XCTAssertEqual(result2.minute, 5)
    }
    
    func test_that_we_can_produce_a_iso8601_duration_string() {
        
        let comps       = NSDateComponents()
        comps.hour      = 1
        comps.minute    = 30
        comps.second    = 23
        
        let result = comps.iso8601Duration
        XCTAssertNotNil(result)
        XCTAssertEqual("PT1H30M23S", result)
        
        let comps2    = NSDateComponents()
        comps2.second = 50
        let result2   = comps2.iso8601Duration
        XCTAssertNotNil(result2)
        XCTAssertEqual("PT50S", result2)

    }
    
    func test_that_we_can_get_components_from_a_timeinterval() {
        
        let timescale: UInt32 = 30_000
        let duration  = TimeInterval(timescale * 10)
        let comps     = NSDateComponents.duration(from: duration, timescale: timescale)
        XCTAssertNotNil(comps)
        XCTAssertEqual(10, comps.second)
        XCTAssertEqual("PT10S", comps.iso8601Duration)
        
        let duration2  = TimeInterval(timescale * (60 * 60))
        let comps2     = NSDateComponents.duration(from: duration2, timescale: timescale)
        XCTAssertNotNil(comps2)
        XCTAssertEqual(1, comps2.hour)
        XCTAssertEqual(0, comps2.minute)
        XCTAssertEqual(0, comps2.second)
        XCTAssertEqual("PT1H", comps2.iso8601Duration)

        let duration3  = TimeInterval(timescale * ((60 * 60) * 24))
        let comps3     = NSDateComponents.duration(from: duration3, timescale: timescale)
        XCTAssertNotNil(comps3)
        XCTAssertEqual(1, comps3.day)
        XCTAssertEqual(0, comps3.hour)
        XCTAssertEqual(0, comps3.minute)
        XCTAssertEqual(0, comps3.second)
        XCTAssertEqual("P1DT", comps3.iso8601Duration)

        let thirtyMinutes = TimeInterval(timescale * (60 * 30))
        let oneHour       = thirtyMinutes * 2
        let twoDays       = oneHour * 48
        let tenSeconds    = TimeInterval(timescale * 23)
        let timeTest      = twoDays + oneHour + thirtyMinutes + tenSeconds
        let comps4        = NSDateComponents.duration(from: timeTest, timescale: timescale)
        XCTAssertNotNil(comps4)
        XCTAssertEqual(2, comps4.day)
        XCTAssertEqual(1, comps4.hour)
        XCTAssertEqual(30, comps4.minute)
        XCTAssertEqual(23, comps4.second)
        XCTAssertEqual("P2DT1H30M23S", comps4.iso8601Duration)

    }
    
}
