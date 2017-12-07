struct TRAK: BinarySizedEncodable {
    
    let type: Atom = .trak
    
    var trackHeader: [TKHD] = [TKHD()]
    var mediaAtom: [MDIA]   = [MDIA()]
    
    static func from(_ config: MOOVConfig) -> [TRAK] {
        
        var results: [TRAK] = []
        
        if let videoConfig = config.videoSettings {
            var trak         = TRAK()
            trak.trackHeader = [TKHD.from(videoConfig)]
            trak.mediaAtom   = [MDIA.from(videoConfig)]
            results.append(trak)
        }
        
        if let audioConfig = config.audioSettings {
            var trak = TRAK()
            trak.trackHeader = [TKHD.from(audioConfig)]
            trak.mediaAtom   = [MDIA.from(audioConfig)]
            results.append(trak)
        }
        
        return results
    }
    
    
}
