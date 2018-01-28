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
    
}
