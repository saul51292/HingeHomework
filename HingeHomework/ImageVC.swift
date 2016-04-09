//
//  ImageVC.swift
//  HingeHomework
//
//  Created by Saul on 4/5/16.
//  Copyright © 2016 Saul. All rights reserved.
//

import UIKit

class ImageVC: UIViewController {

    // Elements linked in Storyboard
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    // Additional Files

    let network = Reachability()
    let fetchImages = FetchImages()

    // Variables

    var currentSelectedSource: Int!
    var imageModelArray:[ImageModel]!
    var cache:NSCache!
    
    // Image Removal Controller
    var alertController:UIAlertController!
    
    // Controls Slideshow
    var timer = NSTimer()
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Remove", style: .Plain, target: self, action: "removeTappedConfirmation")
        
        self.loadNewImageFromModel(self.imageModelArray[self.currentSelectedSource])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "nextImage", userInfo: nil, repeats: true)
        
        // if image is not in cache, check network availability
        if (self.cache.objectForKey(self.imageModelArray[self.currentSelectedSource].imageURL) == nil){
            self.activityIndicator.stopAnimating()
            // if network connected, download image
            network.ifIsConnected(self) { () -> Void in
                self.activityIndicator.startAnimating()
                self.loadNewImageFromModel(self.imageModelArray[self.currentSelectedSource])
            }
        }
    }
    
    
    // Makes sure to clear image and activate activity indicator so user knows image is being loaded in
    // from cache or downloaded from source

    func loadNewImageFromModel(imageModel:ImageModel){
        
        // if image is downloaded from source
        
        if (self.cache.objectForKey(imageModel.imageURL) != nil){
            
            // removes No Internet View if connection is unavailable
            network.removeFromView()

            // sets image if found in cache
            
            mainImageView.image = self.cache.objectForKey(imageModel.imageURL) as? UIImage
            contentModeForImages(mainImageView.image!)
            self.activityIndicator.stopAnimating()
            self.title = "\(currentSelectedSource+1)/\(imageModelArray.count)"
            self.isLoaded = true
            
        }else{
            // if image not found in source, stops timer and starts downloading image
            self.isLoaded = false
            timer.invalidate()
            fetchImages.loadIfNotFound(imageModel.imageURL, completion: { (result,error) -> () in
                if(error == nil){
                    let img:UIImage! = UIImage(data: result!)
                    guard img != nil else{
                        self.removeTapped()
                        self.isLoaded = true
                        self.nextImage()
                        return
                    }
                    // sets image once downloaded from source
                    self.mainImageView.image = img
                    self.contentModeForImages(img)
                    self.cache.setObject(img!, forKey: imageModel.imageURL)
                    self.setTitleAndContinueTimer()
                }
            })
        }
    }
    
    // MARK: - Slideshow Functions

    
    // restarts slideshow, sets title, and stops activityIndicator once image is loaded in

    func setTitleAndContinueTimer(){
        self.isLoaded = true
        self.activityIndicator.stopAnimating()
        self.title = "\(self.currentSelectedSource+1)/\(self.imageModelArray.count)"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "nextImage", userInfo: nil, repeats: true)
    }
    
    // If image is loaded and timer hits this function, the next image is fetched. 
    // If user was on last image, currentSelectedSource is reset to 0 and slideshow is restarted.
    
    func nextImage(){
        if(isLoaded){
            currentSelectedSource! += 1
            if(currentSelectedSource >= imageModelArray.count){
                currentSelectedSource = 0
            }
            isLoaded = false
            loadNewImageFromModel(imageModelArray[currentSelectedSource])
        }
       
    }
    
    // Checks and resizes content for ImageVC
    // Important: Different than the contentMode extension in Extensions.swift because that method sizes most of the
    // images to be .ScaleAspectFill (to better fill the cell) but in ImageVC, most images need to be .ScaleAspectFit
    
    func contentModeForImages(img:UIImage){
        let smallImage = (img.size.height <= 100 || img.size.width <= 100) ? true : false
        if(smallImage == true){
            mainImageView.contentMode = .Center
        }else{
            mainImageView.contentMode = .ScaleAspectFit
        }
    }

    
    // MARK: - Removing Image
    
    // Shows user Remove Image UIAlertController. Also invalidates timer so as to not have the app advance
    // to the next image and subsequently remove the wrong image.
    
    func removeTappedConfirmation(){
        timer.invalidate()
        alertController = UIAlertController(title: "Remove \(imageModelArray[currentSelectedSource].imageName)?", message:  "Are you sure you want to remove this?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.Destructive) { (alert) -> Void in
            
            self.removeTapped()
            self.navigationController?.popViewControllerAnimated(true)
            
            })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (alert) -> Void in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "nextImage", userInfo: nil, repeats: true)
            self.dismissViewControllerAnimated(true, completion: nil)
            })
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // If image is selected to be removed, the parentVC (ImageCollectionVC) is called to run removal functions.
    // The image is then removed from the data source
    
    func removeTapped(){
        if let parentVC = self.navigationController?.viewControllers.first {
            if let parentVC = parentVC as? ImageCollectionVC {
                parentVC.remove(currentSelectedSource)
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
