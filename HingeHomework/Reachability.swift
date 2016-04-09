//
//  Reachability.swift
//  HingeHomework
//
//  Created by Saul on 4/7/16.
//  Copyright © 2016 Saul. All rights reserved.
//

import SystemConfiguration
import UIKit

public class Reachability {
    
    let tryAgainButton = UIButton(frame: CGRectMake(0,UIScreen.mainScreen().bounds.height-80,UIScreen.mainScreen().bounds.width,80))
    let noInternetImageView = UIImageView(frame: CGRectMake(0,0,150,150))
    let noInternetImage = UIImage(named: "cry")
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    // if user is not connected to network, creats No Internet View (ViewController agnostic)
    // if user is connected, removes view and allows viewcontroller to dictate function to run
    
    func ifIsConnected(vc:UIViewController,completion: () -> Void){
        if(!isConnectedToNetwork()){
            createDidNotLoadElements(vc)
        }else{
            removeFromView()
            completion()
        }
       
    }
    
    // removes No Internet View if it's in the superview
    
    func removeFromView(){
        if(tryAgainButton.superview != nil || noInternetImageView.superview != nil ){
            tryAgainButton.removeFromSuperview()
            noInternetImageView.removeFromSuperview()
        }
    }
    
    // creates No Internet View and connects try again button to ViewDidLoad of presentingViewController
    
    func createDidNotLoadElements(vc:UIViewController){
        
        tryAgainButton.setTitle("Try Again", forState: .Normal)
        tryAgainButton.backgroundColor = UIColor(red: 13/255, green: 153/255, blue: 210/255, alpha: 1.0)
        tryAgainButton.addTarget(vc, action: "viewDidLoad", forControlEvents: .TouchUpInside)
        tryAgainButton.setTitleColor(UIColor.darkGrayColor(), forState: .Highlighted)
        vc.view.addSubview(tryAgainButton)

        
        noInternetImageView.image = noInternetImage
        noInternetImageView.contentMode = .ScaleAspectFill
        noInternetImageView.center = vc.view.center
        vc.view.addSubview(noInternetImageView)
        
        
    }

}