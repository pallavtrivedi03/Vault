//
//  DragDropAreView.swift
//  DemoMacApp
//
//  Created by Pallav Trivedi on 05/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import Cocoa

protocol DragDropViewDelegate {
    func dragView(didDragFileWith URL: NSURL)
}

class DragDropAreView: NSView {

    private var fileTypeIsOk = false
    private var acceptedFileExtensions = ["jpg"]
     var delegate: DragDropViewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        fileTypeIsOk = checkExtension(drag: sender)
        return []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let draggedFileURL = sender.draggedFileURL else {
            return false
        }
        
        if fileTypeIsOk {
            delegate?.dragView(didDragFileWith: draggedFileURL)
        }
        
        return true
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
