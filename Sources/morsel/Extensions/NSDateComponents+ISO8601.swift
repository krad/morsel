import Foundation

extension NSDateComponents {
    
    internal enum DurationDesignator: String {
        case period = "P"
        case time   = "T"
    }
    
    internal enum DurationComponent {
        case years(value: NSNumber)
        case months(value: NSNumber)
        case weeks(value: NSNumber)
        case days(value: NSNumber)
        case hours(value: NSNumber)
        case minutes(value: NSNumber)
        case seconds(value: NSNumber)
        
        static func from(character: Character,
                         value: NSNumber,
                         designator: DurationDesignator) -> DurationComponent?
        {
            var result: DurationComponent?
            switch character {
            case "Y": result = .years(value: value)
            case "M": result = designator == .period ? .months(value: value) : .minutes(value: value)
            case "W": result = .weeks(value: value)
            case "D": result = .days(value: value)
            case "H": result = .hours(value: value)
            case "S": result = .seconds(value: value)
            default:  result = nil
            }
            return result
        }
        
        var representation: String {
            switch self {
            case .years:   return "Y"
            case .months,
                 .minutes: return "M"
            case .weeks:   return "W"
            case .days:    return "D"
            case .hours:   return "H"
            case .seconds: return "S"
            }
        }
        
        var designator: DurationDesignator {
            switch self {
            case .years, .months, .weeks, .days: return .period
            case .hours, .minutes, .seconds:     return .time
            }
        }
        
    }
    
    /// Parses a ISO8601 duration string and returns a NSDateComponents object representing it.
    /// See: http://en.wikipedia.org/wiki/ISO_8601#Durations
    ///
    /// P is the duration designator (for period) placed at the start of the duration representation.
    /// Y is the year designator that follows the value for the number of years.
    /// M is the month designator that follows the value for the number of months.
    /// W is the week designator that follows the value for the number of weeks.
    /// D is the day designator that follows the value for the number of days.
    /// T is the time designator that precedes the time components of the representation.
    /// H is the hour designator that follows the value for the number of hours.
    /// M is the minute designator that follows the value for the number of minutes.
    /// S is the second designator that follows the value for the number of seconds.
    ///
    /// - Parameter the8601durationString: A valid ISO8601 duration string
    /// - Returns: NSDateComponent object filled with appropriate values from the string
    internal class func duration(from the8601durationString: String) -> NSDateComponents {
        let comps   = self.parse(the8601durationString)
        let result  = NSDateComponents()
        comps.forEach {
            switch $0 {
            case .years(let value):   result.year = value.intValue
            case .months(let value):  result.month = value.intValue
            case .weeks(let value):   result.weekOfYear = value.intValue
            case .days(let value):    result.day = value.intValue
            case .hours(let value):   result.hour = value.intValue
            case .minutes(let value): result.minute = value.intValue
            case .seconds(let value): result.second = value.intValue
            }
        }
        return result
    }
    
    
    /// Used to parse a ISO8601 Duration string
    ///
    /// - Parameter timeString: ISO8601 Duration string
    /// - Returns: An array of DurationComponents
    internal class func parse(_ timeString: String) -> [DurationComponent]
    {
        var currentSection: DurationDesignator = .period
        var currentComponent: DurationComponent?
        var results: [DurationComponent] = []
        var currentValue = ""
        
        timeString.enumerated().forEach { (offset, element) in
            if let nextSection = DurationDesignator(rawValue: String(element)) {
                currentSection = nextSection
            } else {
                var value: NSNumber = 0
                if let cv = currentValue.numberValue { value = cv }
                
                if let nextComponent = DurationComponent.from(character: element,
                                                              value: value,
                                                              designator: currentSection)
                {
                    if let cc = currentComponent { results.append(cc) }
                    currentComponent = nextComponent
                    currentValue     = ""
                    
                    // We're on the last value
                    if offset >= timeString.underestimatedCount-1 { results.append(nextComponent) }
                } else {
                    currentValue.append(element)
                }
                
            }
        }
        
        return results
    }
    
    internal var iso8601Duration: String? {
        let periodUnits: [NSCalendar.Unit] = [.year, .month, .weekOfYear, .day]
        let timeUnits: [NSCalendar.Unit]   = [.hour, .minute, .second]
        
        let periodValues = periodUnits.flatMap(strForUnit)
        let timeValues   = timeUnits.flatMap(strForUnit)
        
        return ["P", periodValues.joined(), "T", timeValues.joined()].joined()
    }
    
    private func strForUnit(unit: NSCalendar.Unit) -> String? {
        let value = self.value(forComponent: unit)
        if value == Int.max { return nil }
        switch unit {
        case .year:             return "\(value)Y"
        case .month, .minute:   return "\(value)M"
        case .weekOfYear:       return "\(value)W"
        case .day:              return "\(value)D"
        case .hour:             return "\(value)H"
        case .second:           return "\(value)S"
        default:
            return nil
        }
    }
    
}
