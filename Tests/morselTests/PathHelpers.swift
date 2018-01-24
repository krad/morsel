import Foundation

let fixturesPath = findFixturePath()
let outputsPath  = findOutputPath()

private func testsDir() -> String {
    let pieces = #file.components(separatedBy: "/").dropLast()
    return pieces.joined(separator: "/")
}

private func appendToStringHack(path: String) -> String {
    var pieces = testsDir().components(separatedBy: "/")
    pieces.append(path)
    return pieces.joined(separator: "/")
}

private func findFixturePath() -> String {
    return appendToStringHack(path: "fixtures")
}

private func findOutputPath() -> String {
    return appendToStringHack(path: "outputs")
}


