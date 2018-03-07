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
    
    lazy var files = [String: Media]()
    
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
    
    func createDirectory(sourcePath: String, type: MediaType) {
        // path to documents directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            var subDirectoryPath = ""
            switch type
            {
            case .audio:
                subDirectoryPath = documentDirectoryPath.appending("/audios")
            case .video:
                subDirectoryPath = documentDirectoryPath.appending("/videos")
            case .image:
               subDirectoryPath = documentDirectoryPath.appending("/images")
            case .document:
               subDirectoryPath = documentDirectoryPath.appending("/documents")
            }
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: subDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: subDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                    let fileName = sourcePath.components(separatedBy: "/").last
                    let destinationPath = subDirectoryPath.appending("/").appending(fileName!)
                    copyFileToDocumentsDir(sourcePath: sourcePath, desitinationPath: destinationPath)
                } catch {
                    print("Error creating images folder in documents dir: \(error)")
                }
            }
            else
            {
                print("Directory exists")
                let fileName = sourcePath.components(separatedBy: "/").last
                let destinationPath = subDirectoryPath.appending("/").appending(fileName!)
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
    
    func getFilesFromDoucmentDir(type: MediaType)
    {
        // path to documents directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            var subDirectoryPath = ""
            switch type
            {
            case .audio:
                subDirectoryPath = documentDirectoryPath.appending("/audios")
            case .video:
                subDirectoryPath = documentDirectoryPath.appending("/videos")
            case .image:
                subDirectoryPath = documentDirectoryPath.appending("/images")
            case .document:
                subDirectoryPath = documentDirectoryPath.appending("/documents")
            }
            print(subDirectoryPath)
            let fileManager = FileManager.default
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: URL.init(string: subDirectoryPath)! , includingPropertiesForKeys: nil)
                
                for file in fileURLs
                {
                    if !file.absoluteString.contains("DS_Store")
                    {
                    var image = NSImage()
                    switch type
                    {
                    case .audio:
                        image = #imageLiteral(resourceName: "music-player")
                    case .video:
                        image = #imageLiteral(resourceName: "video-player")
                    case .document:
                        image = #imageLiteral(resourceName: "file")
                    case .image:
                        if let i = NSImage(contentsOf: file)
                        {
                            image = i
                        }
                    }
                    let name = String(describing: file).components(separatedBy: "/").last
                    let media = Media(image: image, url: file)
                    files[name!] = media
                    nothingFoundLabel.isHidden = true
                }
                }
                if Array(files.keys).count < 1
                {
                    nothingFoundLabel.isHidden = false
                }
                
            } catch {
                nothingFoundLabel.isHidden = false
                print("Error while enumerating files : \(error.localizedDescription)")
            }
            collectionView.reloadData()
        }
    }
    
    @IBAction func didClickOnExploreButton(_ sender: NSButtonCell)
    {
        toggleViewStates(state: false)
        files = [String:Media]()
        switch sender.tag {
        case 101:
            getFilesFromDoucmentDir(type: .image)
        case 102:
            getFilesFromDoucmentDir(type: .video)
        case 103:
            getFilesFromDoucmentDir(type: .audio)
        case 104:
            getFilesFromDoucmentDir(type: .document)
        default:
            break
        }
    }
    
    func toggleViewStates(state: Bool)
    {
        borderedScrollView.isHidden = state
        dragDropAreaView.isHidden = !state
        dragDropMessageContainer.isHidden = !state
    }
    
    @IBAction func didClickOnAddFileButton(_ sender: NSButton)
    {
        toggleViewStates(state: true)
        nothingFoundLabel.isHidden = true
        files = [String: Media]()
    }
}

extension HomeViewController: DragDropViewDelegate
{
    func draggedMediaType(type: MediaType, url: NSURL) {
        switch type {
        case .audio:
            self.createDirectory(sourcePath: url.absoluteString!, type: .audio)
        case .video:
            self.createDirectory(sourcePath: url.absoluteString!, type: .video)
        case .image:
            self.createDirectory(sourcePath: url.absoluteString!, type: .image)
        case .document:
            self.createDirectory(sourcePath: url.absoluteString!, type: .document)
        }
    }
}

extension HomeViewController: NSCollectionViewDataSource, NSCollectionViewDelegate
{
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CollectionViewItem", for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        
        let mediaName = Array(files.keys)[indexPath.item]
        collectionViewItem.imageView?.image = files[mediaName]?.image
        collectionViewItem.textField?.stringValue = mediaName
        return item
    }
}

struct Media
{
    var image = NSImage()
    var url = URL(string: "")
    
    init(image:NSImage, url:URL)
    {
        self.image = image
        self.url = url
    }
    
}
