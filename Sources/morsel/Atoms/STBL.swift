struct STBL: BinarySizedEncodable {
    
    let type: Atom = .stbl
    
    var sampleDescriptionAtom: [STSD] = [STSD()]
    var timeToSampleAtom: [STTS] = [STTS()]
//    var compositionOffsetAtom = CTTS()
//    var compositionShiftLeastGreatestAtom = CSLG()
//    var syncSampleAtom = STSS()
//    var partialSyncSampleAtom = STPS()
    var sampleToChunkAtom: [STSC] = [STSC()]
    var sampleSizeAtom: [STSZ] = [STSZ()]
    var chunkOffsetAtom: [STCO] = [STCO()]
//    var shadowSyncAtom = STSH()
//    var sampleGroupDescriptionAtom = SGPD()
//    var sampleToGroupAtom = SBGP()
//    var sampleDependenyFlagAtom = SDTP()
    
    static func from(config: MOOVVideoSettings) -> STBL {
        var stbl = STBL()
        stbl.sampleDescriptionAtom = [STSD.from(config)]
        return stbl
    }
    
    static func from(config: MOOVAudioSettings) -> STBL {
        var stbl = STBL()
        stbl.sampleDescriptionAtom = [STSD.from(config)]
        return stbl
    }
    
}
