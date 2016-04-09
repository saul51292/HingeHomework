//
//  ThumbnailCell.swift
//  HingeHomework
//
//  Created by Saul on 4/5/16.
//  Copyright © 2016 Saul. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        styleCell()   
    }
    
    // Helps with smoother scrolling and keeps app from loading images into the wrong cells
    
    override func prepareForReuse() {
        imageView.image = UIImage(named:"blank")
        activityIndicator.startAnimating()
        super.prepareForReuse()
    }
    
    // Styles all cells
    
    func styleCell(){
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.imageView.image = UIImage(named:"blank")
        self.cellLabel.text = "Loading..."
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    // Sets cells with new image
    
    func setCellsOnceImageIsDownloaded(imageToSet:UIImage){
        imageView?.image = imageToSet
        imageView.changeContentMode()
        activityIndicator.stopAnimating()
        setNeedsDisplay()
    }

}
