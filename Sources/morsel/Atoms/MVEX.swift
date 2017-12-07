struct MVEX: BinarySizedEncodable {
    
    let type: Atom = .mvex
    var trackExAtoms: [TREX] = [TREX()]
    
    static func from(_ config: MOOVConfig) -> MVEX {
        var mvex = MVEX()
        
        var tracks: [TREX] = []
        
        if let videoSettings = config.videoSettings {
            let trex = TREX.from(videoSettings)
            tracks.append(trex)
        }
        
        if let audioSettings = config.audioSettings {
            let trex = TREX.from(audioSettings)
            tracks.append(trex)
        }
        
        mvex.trackExAtoms = tracks
        
        return mvex
    }
    
}
