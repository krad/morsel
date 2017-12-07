// Media Data Atom
struct MDAT: BinaryEncodable {
    
    let type: Atom = .mdat
    private var data: [UInt8] = []
    
    init(samples: [Sample]) {
        let videoSamples = samples.filter { $0.type == .video } as! [VideoSample]
        let audioSamples = samples.filter { $0.type == .audio } as! [AudioSample]
        
        videoSamples.forEach { data.append(contentsOf: $0.data) }
        audioSamples.forEach { data.append(contentsOf: $0.data) }
    }
    
}
