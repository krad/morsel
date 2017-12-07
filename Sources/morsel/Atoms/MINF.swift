struct MINF: BinarySizedEncodable {
    
    let type: Atom = .minf
    var videoMediaInformationAtom: [VMHD]?
    var soundMediaInformationAtom: [SMHD]?
    
    var dataInformationAtom: [DINF] = [DINF()]
    var sampleTableAtom: [STBL] = [STBL()]
    
    static func from(_ config: MOOVVideoSettings) -> MINF {
        var minf = MINF()
        minf.videoMediaInformationAtom = [VMHD()]
        minf.soundMediaInformationAtom = nil
        minf.sampleTableAtom = [STBL.from(config: config)]
        return minf
    }

    static func from(_ config: MOOVAudioSettings) -> MINF {
        var minf = MINF()
        minf.videoMediaInformationAtom = nil
        minf.soundMediaInformationAtom = [SMHD()]
        minf.sampleTableAtom           = [STBL.from(config: config)]
        return minf
    }

    
}
