//
//  CollectionViewItem.swift
//  DemoMacApp
//
//  Created by Pallav Trivedi on 06/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
}
