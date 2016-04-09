//
//  Extentions.swift
//  HingeHomework
//
//  Created by Saul on 4/6/16.
//  Copyright © 2016 Saul. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func changeContentMode() -> UIViewContentMode{
        
        let bigImage = (self.image!.size.height >= 5000 || self.image!.size.width >= 5000) ? true : false
        let smallImage = (self.image!.size.height <= 100 || self.image!.size.width <= 100) ? true : false
        
        if(bigImage){
            self.contentMode = .ScaleAspectFit
        }else if(smallImage){
            self.contentMode = .Center
        }else{
            self.contentMode = .ScaleAspectFill
        }
        return self.contentMode
    }
}
