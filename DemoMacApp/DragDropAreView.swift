//
//  DragDropAreView.swift
//  DemoMacApp
//
//  Created by Pallav Trivedi on 05/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import Cocoa
import AppKit

protocol DragDropViewDelegate {
    func dragView(didDragFileWith URL: NSURL)
}

class DragDropAreView: NSView {

    private var fileTypeIsOk = false
    private var acceptedFileExtensions = ["jpg"]
     var delegate: DragDropViewDelegate?
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = 10
            path.stroke()
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        fileTypeIsOk = checkExtension(drag: sender)
        isReceivingDrag = fileTypeIsOk
        return []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        isReceivingDrag = false
        guard let draggedFileURL = sender.draggedFileURL else {
            return false
        }
        
        if fileTypeIsOk {
            delegate?.dragView(didDragFileWith: draggedFileURL)
        }
        
        return true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        guard let fileExtension = drag.draggedFileURL?.pathExtension?.lowercased() else {
            return false
        }
        
        return acceptedFileExtensions.contains(fileExtension)
    }

    
}

extension NSDraggingInfo {
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? [String]
        let path = filenames?.first
        
        return path.map(NSURL.init)
    }
}
