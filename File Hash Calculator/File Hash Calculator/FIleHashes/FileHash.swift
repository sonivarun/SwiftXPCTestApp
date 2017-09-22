//
//  FileHash.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

class FileHash {
    let filePath: String
    let hashValue: String?
    
    init(filePath: String, hashValue: String? = nil) {
        self.filePath = filePath
        self.hashValue = hashValue
    }
}
