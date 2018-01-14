import Foundation
import AEXML

class DashVODPlaylist {
    
    private var document: AEXMLDocument
    private var mpd: AEXMLElement
    
    init() {
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
        
        let representation = adaptationSet.addChild(name: "Representation",
                                                    value: nil,
                                                    attributes: ["id":"base",
                                                                 "bandwidth": "80000",
                                                                 "width": "480",
                                                                 "height": "640"])
        
        let segmentList = representation.addChild(name: "SegmentList",
                                                  value: nil,
                                                  attributes: ["timescale":"44100"])
    }
    
    func show() {
        print("=======")
        print(self.document.xml)
        print("=======")
    }
    
}
