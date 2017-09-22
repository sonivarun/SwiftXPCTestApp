//
//  XPCHashCalculator.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Foundation

class XPCHashCalculator: NSObject, HashCalculator, HashCalculationProgressObserver {
    private weak var serviceConnection: NSXPCConnection?
    private(set) var isCalculating = false
    
    override init() {
        super.init()
        serviceConnection = NSXPCConnection(serviceName: "ksi.Hash-Calculation-Service")
        serviceConnection!.remoteObjectInterface = NSXPCInterface(with: HashCalculationService.self)
        serviceConnection!.exportedInterface = NSXPCInterface(with: HashCalculationProgressObserver.self)
        serviceConnection!.exportedObject = self
        serviceConnection!.interruptionHandler = {
            self.finishCalculationIfNeeded()
        }
        serviceConnection!.resume()
    }
    
    deinit {
        serviceConnection?.invalidate()
    }
    
    // MARK: - HashCalculator
    
    weak var delegate: HashCalculatorDelegate?
    
    func calculateHash(forFilesAtPaths filePaths: [String],
                       usingAlgorithm algorithm: HashAlgorithm) {
        guard !isCalculating else {
            print("Cannot start calculation. Calculator is busy.")
            assert(false)
            return
        }
        
        guard let connection = serviceConnection else {
            print("Cannot send message to remote object. Connection was invalidated.")
            assert(false)
            finishCalculationIfNeeded()
            return
        }
        
        let calculator = connection.remoteObjectProxyWithErrorHandler {
            error in
            print("Remote proxy error: \(error)")
            self.finishCalculationIfNeeded()
            } as! HashCalculationService
        
        isCalculating = true
        calculator.calculateHashes(forFilesAtPaths: filePaths as NSArray,
                                   usingAlgorithm: algorithm.rawValue as NSInteger) {
            self.finishCalculationIfNeeded()
        }
    }
    
    func abortCalculation() {
        guard isCalculating else {
            print("Cannot abort calculation. Calculator is idle.")
            assert(false)
            return
        }
        
        guard let connection = serviceConnection else {
            print("Cannot send message to remote object. Connection was invalidated.")
            assert(false)
            self.finishCalculationIfNeeded()
            return
        }
        
        let calculator = connection.remoteObjectProxyWithErrorHandler {
            error in
            print("Remote proxy error: \(error)")
            self.finishCalculationIfNeeded()
            } as! HashCalculationService
        
        calculator.abortCalculation()
        finishCalculationIfNeeded()
    }
    
    // MARK: - HashCalculationProgressObserver
    
    func didCalculateHash(_ hash: NSString?, forFileAtPath path: NSString) {
        delegate?.calculator(self,
                             didCalculateHash: hash as String?,
                             forFileAtPath: path as String)
    }
    
    // MARK: - Private
    
    private func finishCalculationIfNeeded() {
        if isCalculating {
            isCalculating = false
            delegate?.calculatorDidFinishCalculation(self)
        }
    }
}
