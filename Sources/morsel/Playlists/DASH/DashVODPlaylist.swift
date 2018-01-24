import Foundation
import AEXML

struct DashVODPlaylist {
    
    private var document: AEXMLDocument
    private var mpd: AEXMLElement
    
    init(_ representation: Representation) {
        self.document = AEXMLDocument()
        let mpdAttrs = ["xmlns": "urn:mpeg:dash:schema:mpd:2011",
                        "profiles": "urn:mpeg:dash:profile:full:2011",
                        "minBufferTime": "PT1.5S"]
        
        self.mpd     = self.document.addChild(name: "MPD", attributes: mpdAttrs)
        
        let period   = self.mpd.addChild(name: "Period",
                                         value: nil,
                                         attributes: ["duration": "PT5M"])
        
        let adaptationSet = period.addChild(name: "AdaptationSet",
                                            value: nil,
                                            attributes: ["mimeType":"video/mp4"])
        
        let rep = adaptationSet.addChild(name: "Representation",
                                                    value: nil,
                                                    attributes: ["id":"base",
                                                                 "bandwidth": "80000",
//                                                                 "width": String(representation.videoSettings!.width),
//                                                                 "height": String(representation.videoSettings!.height)
            ])
        
        let segmentList = rep.addChild(name: "SegmentList",
                                       value: nil,
                                       attributes: [
//                                        "timescale": String(representation.?videoSettings!.timescale),
                                                    "duration": String(Int64(representation.duration))])
        
        for segment in representation.segments {
            segmentList.addChild(name: "SegmentURL", value: nil, attributes: ["media": segment.url.lastPathComponent])
        }
    }
    
    func show() {
        print("=======")
        print(self.document.xml)
        print("=======")
    }
    
}
