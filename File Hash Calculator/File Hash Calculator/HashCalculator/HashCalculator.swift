//
//  HashCalculator.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

protocol HashCalculator: class {
    var delegate: HashCalculatorDelegate? { get set }
    var isCalculating: Bool { get }
    
    func calculateHash(forFilesAtPaths: [String], usingAlgorithm: HashAlgorithm)
    func abortCalculation()
}
