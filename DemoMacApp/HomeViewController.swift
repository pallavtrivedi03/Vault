//
//  HomeViewController.swift
//  DemoMacApp
//
//  Created by Pallav Trivedi on 05/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController {

    @IBOutlet weak var docExploreButton: NSButtonCell!
    @IBOutlet weak var audioExploreButton: NSButtonCell!
    @IBOutlet weak var videoExploreButton: NSButtonCell!
    @IBOutlet weak var imageExploreButton: NSButtonCell!
    @IBOutlet weak var collectionView: NSScrollView!
    @IBOutlet weak var dragDropMessageContainer: NSView!
    @IBOutlet weak var dragDropAreaView: DragDropAreView!
    override func viewDidLoad() {
        super.viewDidLoad()
        dragDropAreaView.delegate = self
        setupView()
    }
    
    func setupView()
    {
        imageExploreButton.backgroundColor = #colorLiteral(red: 0.9685459733, green: 0.9686813951, blue: 0.9685032964, alpha: 1)
        videoExploreButton.backgroundColor = #colorLiteral(red: 0.9685459733, green: 0.9686813951, blue: 0.9685032964, alpha: 1)
        audioExploreButton.backgroundColor = #colorLiteral(red: 0.9685459733, green: 0.9686813951, blue: 0.9685032964, alpha: 1)
        docExploreButton.backgroundColor   = #colorLiteral(red: 0.9685459733, green: 0.9686813951, blue: 0.9685032964, alpha: 1)
    }
    
    func createImagesFolder(sourcePath: String) {
        // path to documents directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            let imagesDirectoryPath = documentDirectoryPath.appending("/images")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: imagesDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: imagesDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                    let imageName = sourcePath.components(separatedBy: "/").last
                    let destinationPath = imagesDirectoryPath.appending("/").appending(imageName!)
                    copyFileToDocumentsDir(sourcePath: sourcePath, desitinationPath: destinationPath)
                } catch {
                    print("Error creating images folder in documents dir: \(error)")
                }
            }
            else
            {
                print("Directory exists")
                let imageName = sourcePath.components(separatedBy: "/").last
                let destinationPath = imagesDirectoryPath.appending("/").appending(imageName!)
                copyFileToDocumentsDir(sourcePath: sourcePath, desitinationPath: destinationPath)
            }
        }
    }
    
    func copyFileToDocumentsDir(sourcePath: String, desitinationPath: String) {
        let filemgr = FileManager.default
        if !filemgr.fileExists(atPath: desitinationPath)
        {
            do {
                let startIndex = sourcePath.index(sourcePath.startIndex, offsetBy: 7)
                let trimmedSourcePath = sourcePath[startIndex...]
                try filemgr.moveItem(atPath: String(trimmedSourcePath), toPath: desitinationPath)
            }catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        else
        {
            print("file exists")
        }
    }
    
    
    @IBAction func didClickOnExploreButton(_ sender: NSButtonCell)
    {
        toggleViewStates(state: false)
        
        switch sender.tag {
        case 101:
            print("Images")
        case 102:
            print("Videos")
        case 103:
            print("Audios")
        case 104:
            print("Docs")
        default:
            break
        }
    }
    
    func toggleViewStates(state: Bool)
    {
        collectionView.isHidden = state
        dragDropAreaView.isHidden = !state
        dragDropMessageContainer.isHidden = !state
    }
    
    
}

extension HomeViewController: DragDropViewDelegate
{
    func dragView(didDragFileWith URL: NSURL) {
        self.createImagesFolder(sourcePath: URL.absoluteString!)
    }
}
