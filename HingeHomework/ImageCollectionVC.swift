//
//  ImageCollectionVC.swift
//  HingeHomework
//
//  Created by Saul on 4/5/16.
//  Copyright © 2016 Saul. All rights reserved.

//  Purpose: Control how each cell is displayed and when images are loaded

import UIKit

private let reuseIdentifier = "Thumbnail"

class ImageCollectionVC: UICollectionViewController {

    // Additional Files
    
    let fetchImages = FetchImages()
    let network = Reachability()
    
    // Variables
    
    var imageModelArray:[ImageModel]!
    var tableData:[AnyObject]!
    var cache:NSCache!
    var keepLoadingBigImage:String!
    
    
    // ImageCollectionVC Start
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check Network Availibility
        self.imageModelArray = [ImageModel]()
        network.ifIsConnected(self) { () -> Void in
            // Start fetching data
                self.fetchImages.imageModelLoader(self.didLoadImages)
        }
        
        // Set Up Cache
    
        self.cache = NSCache()

        // Register cell classes
        
        let nib = UINib(nibName: "ThumbnailCell", bundle: nil)
        self.collectionView!.registerNib(nib, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Set HomePage Title
        
        self.title = "Home"
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Image Loading
    
    func didLoadImages(images: [ImageModel]){
        self.imageModelArray = images
        collectionView?.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView?.reloadData()
        
    }
    
       
    // MARK: - Image Removal
    
    // Removes model from cache
    
    func removeFromCache(itemNumberToRemove: Int){
        if (self.cache.objectForKey(self.imageModelArray[itemNumberToRemove].imageURL) != nil){
            self.cache.removeObjectForKey(self.imageModelArray[itemNumberToRemove].imageURL)
        }
        imageModelArray.removeAtIndex(itemNumberToRemove)

    }
    
    // Removes model from collectionview

    func remove(itemNumberToRemove: Int) {
        removeFromCache(itemNumberToRemove)
        let indexPath: NSIndexPath = NSIndexPath(forRow: itemNumberToRemove, inSection: 0)
        self.collectionView!.performBatchUpdates({
            self.collectionView!.deleteItemsAtIndexPaths([indexPath])
            }, completion: {
                (finished: Bool) in
                self.collectionView!.reloadItemsAtIndexPaths(self.collectionView!.indexPathsForVisibleItems())
                self.collectionView!.reloadData()
        })
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Moves to Image View
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cellModel = imageModelArray[indexPath.row]
        fetchImages.cancelAllRequestsExceptNext(cellModel.imageURL)
        self.performSegueWithIdentifier("goToImageView", sender: indexPath.row)
    }
    
    // Controls how many cells are displayed based on number of JSON objects loaded
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageModelArray.count
    }

    // Displays the cells
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ThumbnailCell
        
        // Configure the cell
        let cellModel = imageModelArray[indexPath.row]
        
        // change the cell label text
        cell.cellLabel.text = cellModel.imageName.uppercaseString
        
        // if cell image is already in cache, that image is used
        
        if (self.cache.objectForKey(cellModel.imageURL) != nil){
            let image = self.cache.objectForKey(cellModel.imageURL) as! UIImage
            cell.setCellsOnceImageIsDownloaded(image)
        }else{
            
            // if cell image is not already in cache, that image is downloaded
            
            fetchImages.loadIfNotFound(cellModel.imageURL, completion: { (result,error) -> () in
                if(error == nil){
                    if let updateCell:ThumbnailCell = self.collectionView!.cellForItemAtIndexPath(indexPath) as? ThumbnailCell {
                        let img:UIImage! = UIImage(data: result!)
                        
                        //checks to make sure image is valid. If not, that cell is removed
                        
                        guard img != nil else{
                            self.remove(indexPath.row)
                            return
                        }
                        
                        // cell is updated with new image
                        
                        updateCell.setCellsOnceImageIsDownloaded(img)
                        
                        // Once the image is downloaded, it is saved in the cache
                        
                        self.cache.setObject(img!, forKey: cellModel.imageURL)
                    }
                }
            })
        }
        return cell
    }
    
    // MARK: - Resize Cells For Smaller Screens
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if(UIScreen.mainScreen().bounds.height <= 568){
            return CGSizeMake(130, 130)
        }else{
            return CGSizeMake(160, 160)
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let vc = segue.destinationViewController as? ImageVC {
            let cellNumber = sender as! Int
            vc.currentSelectedSource = cellNumber
            vc.imageModelArray = imageModelArray
            vc.cache = cache
            
        }
    }
    

    
   
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
