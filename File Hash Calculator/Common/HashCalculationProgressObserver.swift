//
//  HashCalculationProgressObserver.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Foundation

@objc(HashCalculationProgressObserver) protocol HashCalculationProgressObserver {
    func didCalculateHash(_: NSString?, forFileAtPath: NSString)
}
