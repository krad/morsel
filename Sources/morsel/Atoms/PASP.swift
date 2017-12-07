// This extension specifies the height-to-width ratio of pixels found in the video sample.
// This is a required extension for MPEG-4 and uncompressed Y´CbCr video formats when non-square pixels
// are used. It is optional when square pixels are used.
struct PASP: BinarySizedEncodable {
    
    let type: Atom = .pasp
    
    var hSpacing: UInt32 = 1
    var vSpacing: UInt32 = 1
    
//    4:3 square pixels (composite NTSC or PAL) hSpacing: 1 vSpacing: 1
//    4:3 non-square 525 (NTSC) hSpacing: 10 vSpacing: 11
//    4:3 non-square 625 (PAL) hSpacing: 59 vSpacing: 54
//    16:9 analog (composite NTSC or PAL) hSpacing: 4 vSpacing: 3
//    16:9 digital 525 (NTSC) hSpacing: 40 vSpacing: 33
//    16:9 digital 625 (PAL) hSpacing: 118 vSpacing: 81
//    1920x1035 HDTV (per SMPTE 260M-1992) hSpacing: 113 vSpacing: 118
//    1920x1035 HDTV (per SMPTE RP 187-1995) hSpacing: 1018 vSpacing: 1062
//    1920x1080 HDTV or 1280x720 HDTV hSpacing: 1 vSpacing: 1
    
}
