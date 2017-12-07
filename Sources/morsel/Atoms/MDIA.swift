struct MDIA: BinarySizedEncodable {
    
    let type: Atom = .mdia
    
    var mediaHeaderAtom: [MDHD] = [MDHD()]
    var handlerReferenceAtom: [HDLR] = [HDLR()]
    var mediaInformationAtom: [MINF] = [MINF()]
    
    static func from(_ config: MOOVVideoSettings) -> MDIA {
        var mdia                  = MDIA()
        mdia.mediaHeaderAtom      = [MDHD.from(config)]
        mdia.handlerReferenceAtom = [HDLR.with(sampleType: .video)]
        mdia.mediaInformationAtom = [MINF.from(config)]
        return mdia
    }
    
    static func from(_ config: MOOVAudioSettings) -> MDIA {
        var mdia                  = MDIA()
        mdia.mediaHeaderAtom      = [MDHD.from(config)]
        mdia.handlerReferenceAtom = [HDLR.with(sampleType: .audio)]
        mdia.mediaInformationAtom = [MINF.from(config)]
        return mdia
    }
    
}
