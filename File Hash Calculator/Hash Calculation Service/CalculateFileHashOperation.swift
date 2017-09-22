//
//  CalculateFileHashOperation.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/22/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Foundation

class CalculateFileHashOperation: Operation {
    private let filePath: String
    private let algorithm: HashAlgorithm
    private let completionHandler: (String, String?) -> Void
    private var fileHashValue: String?
    
    init(filePath: String,
         algorithm: HashAlgorithm,
         completionHandler: @escaping (String, String?) -> Void) {
        self.filePath = filePath
        self.algorithm = algorithm
        self.completionHandler = completionHandler
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        if let hashData = calculateFileHashData() {
            fileHashValue = formHexEncodedHashString(fromHashData: hashData)
        }
        
        if !isCancelled {
            completionHandler(filePath, fileHashValue)
        }
    }
    
    // MARK: - Private
    
    private func calculateFileHashData() -> Data? {
        // Simple solution, but hashing large files may eat all your RAM.
        // Ideally it should be done in chunks.
        
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return nil
        }
        
        let digestLength: Int32
        let hashFunction: (UnsafeRawPointer, CC_LONG, UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8>!
        
        switch algorithm {
        case .md5:
            digestLength = CC_MD5_DIGEST_LENGTH
            hashFunction = CC_MD5
        case .sha1:
            digestLength = CC_SHA1_DIGEST_LENGTH
            hashFunction = CC_SHA1
        case .sha256:
            digestLength = CC_SHA256_DIGEST_LENGTH
            hashFunction = CC_SHA256
        }
        
        var hash = [UInt8](repeating: 0,
                           count: Int(digestLength))
        fileData.withUnsafeBytes {
            _ = hashFunction($0, CC_LONG(fileData.count), &hash)
        }
        return Data(bytes: hash)
    }
    
    private func formHexEncodedHashString(fromHashData hashData: Data) -> String {
        return hashData.map { String(format: "%02hhx", $0) }.joined()
    }
}
