//
//  HashCalculatorDelegate.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

protocol HashCalculatorDelegate: class {
    func calculator(_: HashCalculator,
                    didCalculateHash: String?,
                    forFileAtPath: String)
    
    func calculatorDidFinishCalculation(_: HashCalculator)
}
