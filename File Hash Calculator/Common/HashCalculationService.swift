//
//  HashCalculationService.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Foundation

@objc(HashCalculationService) protocol HashCalculationService {
    func calculateHashes(forFilesAtPaths: NSArray,
                         usingAlgorithm: NSInteger,
                         withReply: @escaping () -> Void)
    
    func abortCalculation()
}
