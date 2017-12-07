// This atom is a required extension for uncompressed Y´CbCr data formats.
// The 'colr' extension is used to map the numerical values of pixels in the file to a common representation of color in which images can be correctly compared, combined, and displayed.
struct COLR: BinarySizedEncodable {
    
    let type: Atom = .colr
    var colorParameter: ColorParameter = .videoBMFF
    
    var primariesIndex: UInt16 = 1
    var transferFunctionIndex: UInt16 = 1
    var matrixIndex: UInt16 = 1
    
    var unknown: UInt8 = 0
}

enum ColorParameter: String, BinaryEncodable {
    case video     = "nclc"     // nonconstant luminance coding.
    case videoBMFF = "nclx" // ISO BMFF file
    case print     = "prof"
}
