//
//  CalculationService.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Foundation

class CalculationService: NSObject, HashCalculationService {
    private weak var clientConnection: NSXPCConnection?
    private let operationQueue = OperationQueue()
    private var completionHandler: (() -> Void)?
    private var isCalculating = false
    
    init(clientConnection: NSXPCConnection) {
        self.clientConnection = clientConnection
        super.init()
    }
    
    deinit {
        operationQueue.cancelAllOperations()
        clientConnection?.invalidate()
    }
    
    // MARK: - HashCalculationService
    
    func calculateHashes(forFilesAtPaths paths: NSArray,
                         usingAlgorithm algorithm: NSInteger,
                         withReply replyClosure: @escaping () -> Void) {
        guard !isCalculating else {
            print("Cannot start calculation. Calculation service is busy.")
            assert(false)
            replyClosure()
            return
        }
        
        guard let hashAlgorithm = HashAlgorithm(rawValue: algorithm) else {
            print("Unknown hash algorithm was passed to calculation service. " +
                "Cannot start calculation.")
            assert(false)
            replyClosure()
            return
        }
        
        guard paths.count > 0 else {
            print("No files were passed to calculation service. " +
                "There is nothing to calculate.")
            replyClosure()
            return
        }
        
        isCalculating = true
        completionHandler = replyClosure
        for filePath in paths {
            guard let path = filePath as? String else {
                print("Unsupported filePath format was passed to calculation service. " +
                    "Skipping that file...")
                assert(false)
                replyClosure()
                continue
            }
            
            let operation = CalculateFileHashOperation(filePath: path,
                                                       algorithm: hashAlgorithm,
                                                       completionHandler: {
                                                        [weak self] (path, hash) in
                                                        self?.didCalculateHash(hash,
                                                                               forFileAtPath: path)
            })
            operationQueue.addOperation(operation)
        }
    }
    
    func abortCalculation() {
        guard isCalculating else {
            print("Cannot abort calculation. Calculation service is idle.")
            return
        }

        stopCalculation(shouldCallCompletionHandler: true)
    }
    
    // MARK: - Private
    
    private func didCalculateHash(_ hash: String?, forFileAtPath filePath: String) {
        if isCalculating {
            guard let connection = clientConnection else {
                print("Cannot send message to remote object. Connection was invalidated.")
                assert(false)
                stopCalculation(shouldCallCompletionHandler: false)
                return
            }
            
            let observer = connection.remoteObjectProxy as! HashCalculationProgressObserver
            observer.didCalculateHash(hash as NSString?,
                                      forFileAtPath: filePath as NSString)
            
            if operationQueue.operationCount < 2 {
                // If this is a last operation in the queue -> calculation is finished
                stopCalculation(shouldCallCompletionHandler: true)
            }
        }
    }
    
    private func stopCalculation(shouldCallCompletionHandler: Bool) {
        isCalculating = false
        if shouldCallCompletionHandler {
            completionHandler?()
        }
        completionHandler = nil
        operationQueue.cancelAllOperations()
    }
}
