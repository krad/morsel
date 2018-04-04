import grip

struct MOOV: BinaryEncodable {
    
    let type: Atom = .moov
    
    var movieHeaderAtom: [MVHD] = [MVHD()]
    var tracks: [TRAK] = [TRAK()]
    
    var mediaFragmentInfo: [MVEX] = [MVEX()]
    
    init(_ config: MOOVConfig) {
        
        if let videoSettings = config.videoSettings {
            self.movieHeaderAtom = [MVHD.from(videoSettings)]
        }
        
        if let audioSettings = config.audioSettings {
            if var mvhd = self.movieHeaderAtom.first {
                mvhd.timeScale = audioSettings.sampleRate
                self.movieHeaderAtom = [mvhd]
            }
        }
        
        self.tracks            = TRAK.from(config)
        self.mediaFragmentInfo = [MVEX.from(config)]
    }
        
}
