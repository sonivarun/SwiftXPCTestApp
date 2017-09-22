//
//  main.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Foundation

class ServiceDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener,
                  shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.remoteObjectInterface = NSXPCInterface(with: HashCalculationProgressObserver.self)
        newConnection.exportedInterface = NSXPCInterface(with: HashCalculationService.self)
        newConnection.exportedObject = CalculationService(clientConnection: newConnection)
        newConnection.resume()
        return true
    }
}

let delegate = ServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
