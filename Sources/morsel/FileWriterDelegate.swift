import Foundation

/// Protocol used by classes with file writing responsibilities to notify them when things have been writen or updated
public protocol FileWriterDelegate {
    
    /// Called when a file is written to a particular url
    ///
    /// - Parameter url: URL the file was written to
    func wroteFile(at url: URL)
    
    
    /// Called when a file has been updated
    ///
    /// - Parameter url: URL of the updated file
    func updatedFile(at url: URL)
}
