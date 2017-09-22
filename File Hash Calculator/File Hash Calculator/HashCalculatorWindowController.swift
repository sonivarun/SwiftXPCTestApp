//
//  HashCalculatorWindowController.swift
//  File Hash Calculator
//
//  Created by Tanya on 9/20/17.
//  Copyright © 2017 Slava. All rights reserved.
//

import Cocoa

class HashCalculatorWindowController: NSWindowController, HashCalculatorDelegate, NSTableViewDataSource {
    // MARK: - Outlets
    
    @IBOutlet weak var filesTableView: NSTableView!
    @IBOutlet weak var addFilesButton: NSButton!
    @IBOutlet weak var removeAllFilesButton: NSButton!
    @IBOutlet weak var algorithmSelectionButton: NSPopUpButton!
    @IBOutlet weak var calculationButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    // MARK: -
    
    private let hashCalculator: HashCalculator
    private lazy var fileHashList: FileHashList = {
        let hashList = FileHashList()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.fileHashListContentDidChange(_:)),
                                               name: .fileHashListContentDidChange,
                                               object: hashList)
        return hashList
    }()
    
    init(hashCalculator: HashCalculator) {
        self.hashCalculator = hashCalculator
        super.init(window: nil)
        hashCalculator.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        hashCalculator.delegate = nil
    }
    
    // MARK: - HashCalculatorDelegate
    
    override var windowNibName: String! {
        return "FileHashCalculator"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.progressIndicator.isHidden = true
        updateUIOnContentChange()
    }
    
    // MARK: - HashCalculatorDelegate
    
    func calculator(_ calculator: HashCalculator,
                    didCalculateHash hashValue: String?,
                    forFileAtPath filePath: String) {
        guard calculator === hashCalculator else {
            // Unknown calculator
            return
        }
        
        guard calculator.isCalculating else {
            // Got unexpected didCalculateHash callback when not calculating. Ignoring...
            return
        }
        
        DispatchQueue.main.async {
            do {
                try self.fileHashList.updateHashValue(hashValue,
                                                      forFileAtPath: filePath)
            }
            catch {
                print("Failed to update hash value for file in FileHashList. Error: \(error).")
                assert(false)
            }
            self.progressIndicator.increment(by: 1)
        }
    }
    
    func calculatorDidFinishCalculation(_ calculator: HashCalculator) {
        guard calculator === hashCalculator else {
            // Unknown calculator
            return
        }
        
        DispatchQueue.main.async {
            self.addFilesButton.isEnabled = true
            self.algorithmSelectionButton.isEnabled = true
            self.updateCalculationButtonTitle()
            self.progressIndicator.isHidden = true
            self.updateUIOnContentChange()
        }
    }
    
    // MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard tableView == filesTableView else {
            // Unknown tableView
            return 0
        }
        
        return fileHashList.items.count
    }
    
    func tableView(_ tableView: NSTableView,
                   objectValueFor tableColumn: NSTableColumn?,
                   row: Int) -> Any? {
        guard tableView == filesTableView else {
            // Unknown tableView
            return 0
        }
        
        let columnIdentifier = tableColumn?.identifier
        if columnIdentifier == "path" {
            return fileHashList.items[row].filePath
        }
        else if columnIdentifier == "hash" {
            return fileHashList.items[row].hashValue
        }
        return nil
    }
    
    // MARK: - Actions
    
    @IBAction func addFiles(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        if openPanel.runModal() == NSFileHandlingPanelOKButton {
            let newFileHashes = openPanel.urls.map {
                FileHash(filePath: $0.path)
            }
            fileHashList.add(newFileHashes)
        }
    }
    
    @IBAction func removeAllFiles(_ sender: NSButton) {
        fileHashList.removeAll()
    }
    
    @IBAction func calculationAction(_ sender: NSButton) {
        if hashCalculator.isCalculating {
            hashCalculator.abortCalculation()
        }
        else {
            guard let selectedItem = algorithmSelectionButton.selectedItem,
                let algorithm = HashAlgorithm(rawValue: selectedItem.tag) else {
                print("Unknown hash algorithm is chosen in the algorithm selection popup.")
                assert(false)
                return
            }
            
            addFilesButton.isEnabled = false
            removeAllFilesButton.isEnabled = false
            algorithmSelectionButton.isEnabled = false
            progressIndicator.maxValue = Double(fileHashList.items.count)
            progressIndicator.doubleValue = 0
            self.progressIndicator.isHidden = false
            let filePaths = fileHashList.items.map { $0.filePath }
            hashCalculator.calculateHash(forFilesAtPaths: filePaths,
                                         usingAlgorithm: algorithm)
            updateCalculationButtonTitle()
        }
    }
    
    // MARK: - Private
    
    dynamic private func fileHashListContentDidChange(_ aNotification: Notification) {
        if !hashCalculator.isCalculating {
            updateUIOnContentChange()
        }
    }
    
    private func updateUIOnContentChange() {
        let isEmptyList = fileHashList.items.count == 0
        removeAllFilesButton.isEnabled = !isEmptyList
        calculationButton.isEnabled = !isEmptyList
        filesTableView.reloadData()
    }
    
    private func updateCalculationButtonTitle() {
        if hashCalculator.isCalculating {
            calculationButton.title = NSLocalizedString("Abort",
                                                        comment: "Abort calculation button title")
        }
        else {
            calculationButton.title = NSLocalizedString("Calculate",
                                                        comment: "Start calculation button title")
        }
    }
}
