import Foundation
import AEXML

class DashVODPlaylist: PlaylistGenerator {
    
    var type: PlaylistType = .dash_vod
    internal var representation: Representation?
    internal var fileName: String
    
    required init(fileName: String) {
        self.fileName = fileName
    }
    
    var output: String {
        guard let representation = self.representation,
            representation.segments.count > 0 else { return "" }
        
        let document = AEXMLDocument()
        let mpdAttrs = ["xmlns": "urn:mpeg:dash:schema:mpd:2011",
                        "profiles": "urn:mpeg:dash:profile:full:2011",
                        "type": self.type.rawValue,
                        "maxSegmentDuration": "PT\(representation.targetDuration)S"]
        
        let mpd     = document.addChild(name: "MPD", attributes: mpdAttrs)
        
        let nativeDuration = representation.duration * Double(representation.timescale)
        let periodComps = NSDateComponents.duration(from: nativeDuration,
                                                    timescale: representation.timescale)
        
        var periodAttrs: [String: String] = [:]
        if let periodDurationStr = periodComps.iso8601Duration {
            periodAttrs["duration"] = periodDurationStr
        }
        
        let period   = mpd.addChild(name: "Period",
                                         value: nil,
                                         attributes: periodAttrs)
        
        let adaptationSet = period.addChild(name: "AdaptationSet",
                                            value: nil,
                                            attributes: ["mimeType":"video/mp4"])
        
        var repAttrs = ["id": "base",
                        "bandwidth": "80000"]
        
        if let videoSettings = representation.videoSettings {
            repAttrs["width"]  = String(videoSettings.width)
            repAttrs["height"] = String(videoSettings.height)
        }
        
        let rep = adaptationSet.addChild(name: "Representation",
                                         value: nil,
                                         attributes: repAttrs)
        
        let segmentList = rep.addChild(name: "SegmentList",
                                       value: nil,
                                       attributes: [
                                        "timescale": String(representation.timescale),
                                        "duration": String(Int64(nativeDuration))])
        
        for segment in representation.segments {
            if segment.isIndex {
                segmentList.addChild(name: "Initialization",
                                     value: nil,
                                     attributes: ["sourceURL": segment.url.lastPathComponent])
            } else {
                segmentList.addChild(name: "SegmentURL",
                                     value: nil,
                                     attributes: ["media": segment.url.lastPathComponent])
            }
        }

        return document.xml
    }
    
}
