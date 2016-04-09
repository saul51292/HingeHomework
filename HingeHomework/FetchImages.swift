//
//  FetchImages.swift
//  HingeHomework
//
//  Created by Saul on 4/5/16.
//  Copyright © 2016 Saul. All rights reserved.

//  Purpose: Fetch Images from Server

import UIKit

enum JSONError: String, ErrorType {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
    case BrokenLink = "ERROR: broken image link"
}

class FetchImages {
    
    let sourceURL = "https://hinge-homework.s3.amazonaws.com/client/services/homework.json"
    var download_requests = [String:NSURLSession]()
    
    // creates a generic TaskRequest using NSURLSession
    // This can be used to download any information and has a completion handler to dictate
    // what should be done with the results. Also has built in error checks.
    
    func genericTaskRequest(url:String,completion: (result: NSData) -> Void){
        guard let endpoint = NSURL(string: url) else {
            print("Error creating endpoint")
            return
        }
        let request = NSMutableURLRequest(URL:endpoint)
        let generic = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // add to download_requests dictionary
        
        download_requests[url] = generic
        generic.downloadTaskWithRequest(request) { (location, response, error) in
            if location != nil{
                let data:NSData! = NSData(contentsOfURL:location!)
                do {
                    guard let data = data else {
                        throw JSONError.NoData
                    }
                    completion(result: data)
                } catch let error as JSONError {
                    print(error.rawValue)
                } catch let error as NSError {
                    print(error.debugDescription)
                }
            }
            }.resume()

    }
    
    // loads all information from sourceURL and creates ImageModel
    
    func imageModelLoader(completion: (([ImageModel]) -> Void)!) {
        let url = sourceURL
        genericTaskRequest(url) { (result) -> Void in
            do{
                guard let jsonData = try NSJSONSerialization.JSONObjectWithData(result, options: []) as? [NSDictionary] else {
                    throw JSONError.ConversionFailed
            }
            let images = jsonData
            var imageModel = [ImageModel]()
            for image in images{
                let image = ImageModel(data:image)
                imageModel.append(image)
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)){
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(imageModel)
                            }
                        }
                    }
                }catch {
                print("error");
            }
        }
        
    }
    
    // checks to see if ImageURL returns an existing image
    
    func checkIfExists(string:String,completion:(result:Bool?,error:JSONError?)->()){
        let url:NSURL = NSURL(string: string)!
        if UIApplication.sharedApplication().canOpenURL(url) {
            completion(result: true,error: nil)
        }else{
            completion(result: false,error: JSONError.BrokenLink)

        }
    }
    
    
    // Invalidates and cancels all url requests
    
    // User Story: A User clicks on an image and wants that image to load up asap.
    // This function cancels all current NSURLSessions except for the user selected one.
    // This frees up resources to fetch the selected image fast, without losing any already made progress.
    
    func cancelAllRequestsExceptNext(tappedURL:String){
        for request in download_requests{
            if(tappedURL != request.0){
                request.1.invalidateAndCancel()
            }
        }
    }

    
    // loads an image async if not found

    func loadIfNotFound(url:String, completion: (data:NSData?,error:NSError?) -> ()){
        genericTaskRequest(url) { (result) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: result,error: nil)
            })
        }
    }
}




