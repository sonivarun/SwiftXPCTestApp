//
//  FileHashList.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Foundation

enum FileHashListError: Error {
    case noSuchFile
}

extension NSNotification.Name {
    static let fileHashListContentDidChange = Notification.Name("FileHashListContentDidChange")
}

class FileHashList {
    private var storage = [String: String?]()
    private var orderedCache: [FileHash]?
    
    var items: [FileHash] {
        if orderedCache == nil {
            orderedCache = storage.map { FileHash(filePath: $0, hashValue: $1) }
        }
        return orderedCache!
    }
    
    func add(_ fileHashes: [FileHash]) {
        var contentWasChanged = false
        for fileHash in fileHashes {
            // If file is already in the list -> don't add a duplicate
            guard !storage.keys.contains(fileHash.filePath) else {
                continue
            }
            
            storage[fileHash.filePath] = fileHash.hashValue
            contentWasChanged = true
        }
        if contentWasChanged {
            contentChanged()
        }
    }
    
    func removeAll() {
        storage.removeAll()
        contentChanged()
    }
    
    func updateHashValue(_ hash: String?, forFileAtPath filePath: String) throws {
        guard storage.keys.contains(filePath) else {
            assert(false)
            throw FileHashListError.noSuchFile
        }
        
        storage[filePath] = hash
        contentChanged()
    }
    
    // MARK: - Private
    
    private func contentChanged() {
        orderedCache = nil
        NotificationCenter.default.post(name: .fileHashListContentDidChange, object: self)
    }
}
