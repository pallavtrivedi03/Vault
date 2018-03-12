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
    func draggedMediaType(type:MediaType, url: NSURL)
}

enum MediaType
{
    case image
    case video
    case audio
    case document
}

class DragDropAreView: NSView {

    private var fileTypeIsOk = false
    private var acceptedFileExtensions = ["jpg","png","doc","docx","pdf","mov","mp4","mp3"]
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
        return fileTypeIsOk ? .move : []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        isReceivingDrag = false
        guard let _ = sender.draggedFileURL else {
            return false
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
        
        if acceptedFileExtensions.contains(fileExtension)
        {
            if fileExtension == "jpg" || fileExtension == "png"
            {
                delegate?.draggedMediaType(type: .image, url: drag.draggedFileURL!)
            }
            else if fileExtension == "mp4" || fileExtension == "mov"
            {
                delegate?.draggedMediaType(type: .video, url: drag.draggedFileURL!)
            }
            else if fileExtension == "mp3"
            {
                delegate?.draggedMediaType(type: .audio, url: drag.draggedFileURL!)
            }
            else if fileExtension == "doc" || fileExtension == "docx" || fileExtension == "pdf" || fileExtension == "epub"
            {
                delegate?.draggedMediaType(type: .document, url: drag.draggedFileURL!)
            }
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
