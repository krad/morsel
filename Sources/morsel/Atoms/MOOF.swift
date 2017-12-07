import Foundation

struct MOOF: BinaryEncodable {
    
    let type: Atom = .moof
    
    var movieFragmentHeaderAtom: [MFHD] = [MFHD()]
    var trackFragments: [TRAF] = [TRAF()]
    
    init(config: MOOVConfig,
         samples: [Sample],
         currentSequence: UInt32)
    {
        self.movieFragmentHeaderAtom = [MFHD(sequenceNumber: currentSequence)]
        self.trackFragments          = TRAF.from(samples, config: config)
    }
    
    func binaryEncode(to encoder: BinaryEncoder) throws {
        // Pre encode so we can get size and calculate offset :-/
        let newEncoder = BinaryEncoder()
        try newEncoder.encode(self.type)
        try newEncoder.encode(self.movieFragmentHeaderAtom)
        try newEncoder.encode(self.trackFragments)

        try encoder.encode(self.type)
        try encoder.encode(self.movieFragmentHeaderAtom)

        let padding       = 4 + 4 + 4 // 32bits for moof size, 32bits for mdat size, 32 bits for mdat tag
        var currentOffset = UInt32(newEncoder.data.count + padding) // Size of the moof
        
        for traf in self.trackFragments {
            var xtraf = traf

            var results: [TRUN] = []
            for xrun in traf.trackRun {
                var run        = xrun
                run.dataOffset = Int32(currentOffset)
                currentOffset  += run.samples.reduce(0) { cnt, sample in cnt + sample.size }
                results.append(run)
            }

            xtraf.trackRun = results
            try encoder.encode([xtraf])
        }
        
    }
    
    
}

