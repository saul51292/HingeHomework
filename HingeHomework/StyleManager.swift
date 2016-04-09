//
//  SyleManagert.swift
//  HingeHomework
//
//  Created by Saul on 4/8/16.
//  Copyright © 2016 Saul. All rights reserved.
//

import Foundation
import UIKit

class StyleManager: NSObject {
    
    func styleNavigationBar(navVC:UINavigationController){
        navVC.navigationBar.barTintColor = UIColor(red: 13/255, green: 153/255, blue: 210/255, alpha: 1.0)
        navVC.navigationBar.tintColor = UIColor.whiteColor()
        navVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    }
    
    
}

