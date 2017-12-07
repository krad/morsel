import CoreMedia

struct TRAF: BinarySizedEncodable {
    
    let type: Atom = .traf
    
    var trackFragmentHeader: [TFHD] = [TFHD()]
    var trackDecodeAtom: [TFDT] = [TFDT()]
    var trackRun: [TRUN] = [TRUN()]
    
    static func from(_ samples:[Sample],
                     config: MOOVConfig) -> [TRAF]
    {
        var trackFragments: [TRAF] = []
        
        
        if let _ = config.videoSettings {
            let videoSamples = samples.filter { $0.type == .video } as! [VideoSample]

            if let sample = videoSamples.first {
                var traf                 = TRAF()
                traf.trackFragmentHeader = [TFHD.from(sample: sample)]
                traf.trackDecodeAtom     = [TFDT.from(decode: sample.decode)]
                traf.trackRun            = [TRUN.from(samples: videoSamples)]
                
                trackFragments.append(traf)
            }
        }
        

        if let _ = config.audioSettings {
            let audioSamples = samples.filter { $0.type == .audio } as! [AudioSample]

            if let sample = audioSamples.first {
                var traf                 = TRAF()
                traf.trackFragmentHeader = [TFHD.from(sample: sample)]
                traf.trackDecodeAtom     = [TFDT.from(decode: sample.decode)]
                traf.trackRun            = [TRUN.from(samples: audioSamples)]
                trackFragments.append(traf)
            }
        }
        
        return trackFragments
    }
    
}
