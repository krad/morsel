import Foundation

internal protocol Segment {
    var url: URL { get }
    var duration: Double { get }
    var isIndex: Bool { get }
}

func ==(lhs: Segment, rhs: Segment) -> Bool {
    return lhs.url == rhs.url
}
