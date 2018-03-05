//
//  HomeViewController.swift
//  DemoMacApp
//
//  Created by Pallav Trivedi on 05/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController {

    @IBOutlet weak var dragDropAreaView: DragDropAreView!
    override func viewDidLoad() {
        super.viewDidLoad()
        dragDropAreaView.delegate = self
        // Do view setup here.
    }
    
    func setupView()
    {
  
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
                    print(">>>>>>>>> \(documentDirectoryPath)")
                    let imageName = sourcePath.components(separatedBy: "/").last
                    print("Image name is \(imageName!)")
                    let destinationPath = imagesDirectoryPath.appending("/").appending(imageName!)
                    print("Dest path is \(destinationPath)")
                    copyFileToDocumentsDir(sourcePath: sourcePath, desitinationPath: destinationPath)
                } catch {
                    print("Error creating images folder in documents dir: \(error)")
                }
            }
            else
            {
                print("Directory exists")
                let imageName = sourcePath.components(separatedBy: "/").last
                print("Image name is \(imageName!)")
                let destinationPath = imagesDirectoryPath.appending("/").appending(imageName!)
                print("Dest path is \(destinationPath)")
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
                print("trimmed path is \(trimmedSourcePath)")
//                try filemgr.copyItem(atPath: String(trimmedSourcePath), toPath: desitinationPath)
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
}

extension HomeViewController: DragDropViewDelegate
{
    func dragView(didDragFileWith URL: NSURL) {
        print("source path is \(String(describing: URL.absoluteString))")
        self.createImagesFolder(sourcePath: URL.absoluteString!)
    }
}
