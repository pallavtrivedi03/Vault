//
//  HomeViewController.swift
//  DemoMacApp
//
//  Created by Pallav Trivedi on 05/03/18.
//  Copyright © 2018 Pallav Trivedi. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController
{

    @IBOutlet weak var docExploreButton: NSButtonCell!
    @IBOutlet weak var audioExploreButton: NSButtonCell!
    @IBOutlet weak var videoExploreButton: NSButtonCell!
    @IBOutlet weak var imageExploreButton: NSButtonCell!
    @IBOutlet weak var dragDropMessageContainer: NSView!
    @IBOutlet weak var dragDropAreaView: DragDropAreView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var borderedScrollView: NSScrollView!
    
    @IBOutlet weak var nothingFoundLabel: NSTextField!
    lazy var images = [String:NSImage]()
    
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
    
    override func viewDidAppear() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 120.0)
        flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        
        view.wantsLayer = true
        collectionView.layer?.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        collectionView.frame = dragDropAreaView.frame
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
    
    func getFilesFromDoucmentDir()
    {
        // path to documents directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            let imagesDirectoryPath = documentDirectoryPath.appending("/images")
            let fileManager = FileManager.default
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: URL.init(string: imagesDirectoryPath)! , includingPropertiesForKeys: nil)
                if fileURLs.count > 0
                {
                for file in fileURLs
                {
                    let image = NSImage(contentsOf: file)
                    let name = String(describing: file).components(separatedBy: "/").last
                    images[name!] = image
                    collectionView.reloadData()
                }
                }
                else
                {
                    nothingFoundLabel.isHidden = false
                }
                
            } catch {
                print("Error while enumerating files : \(error.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func didClickOnExploreButton(_ sender: NSButtonCell)
    {
        toggleViewStates(state: false)
        getFilesFromDoucmentDir()
    
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
        borderedScrollView.isHidden = state
        nothingFoundLabel.isHidden = state
        dragDropAreaView.isHidden = !state
        dragDropMessageContainer.isHidden = !state
    }
    
    @IBAction func didClickOnAddFileButton(_ sender: NSButton)
    {
        toggleViewStates(state: true)
        images = [String: NSImage]()
    }
    
    
}

extension HomeViewController: DragDropViewDelegate
{
    func dragView(didDragFileWith URL: NSURL) {
        self.createImagesFolder(sourcePath: URL.absoluteString!)
    }
}

extension HomeViewController: NSCollectionViewDataSource, NSCollectionViewDelegate
{
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        
        let imageName = Array(images.keys)[indexPath.item]
        collectionViewItem.imageView?.image = images[imageName]
        collectionViewItem.textField?.stringValue = imageName
        return item
    }
}


