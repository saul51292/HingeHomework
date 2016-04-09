//
//  ImageModel.swift
//  HingeHomework
//
//  Created by Saul on 4/5/16.
//  Copyright © 2016 Saul. All rights reserved.


// Purpose: Create reusable model for all images

import Foundation


class ImageModel: NSObject{
    var imageName : String!
    var imageDescription : String!
    var imageURL : String!
    
    init(data:NSDictionary) {
        super.init()
        self.imageName = getStringFromJSON(data, key: "imageName")
        self.imageDescription = getStringFromJSON(data, key: "imageDescription")
        self.imageURL = getStringFromJSON(data, key: "imageURL")
    }
    
    func getStringFromJSON(data:NSDictionary, key:String)->String{
        if let info = data[key] as? String{
            return info
        }
        return ""
    }
    
}


