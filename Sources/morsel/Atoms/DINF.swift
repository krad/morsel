import grip

struct DINF: BinarySizedEncodable {
    
    var type: Atom = .dinf
    var dref = [DREF()]
        
}
