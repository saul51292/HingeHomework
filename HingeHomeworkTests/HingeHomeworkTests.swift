//
//  HingeHomeworkTests.swift
//  HingeHomeworkTests
//
//  Created by Saul on 4/5/16.
//  Copyright © 2016 Saul. All rights reserved.
//

import XCTest
@testable import HingeHomework

class HingeHomeworkTests: XCTestCase {
    
    var imageModelArray = [ImageModel]()
    let fetchImages = FetchImages()
    var imageController:ImageCollectionVC!
    
    let firstMock:NSDictionary = [
        "imageURL": "http://pop.h-cdn.co/assets/15/31/980x775/gallery-1438368282-golden-toad.jpg",
        "imageDescription": "Golden Toad",
        "imageName": "Toad"
    ]
    let secondMock:NSDictionary = [
        "imageURL": "http://pop.h-cdn.co/assets/cm/15/05/54ca698969ab3_-_zanzibarleopard-lg.jpg",
        "imageDescription": "Zanzibar Leopard",
        "imageName": "Leopard"
    ]
    let thirdMock:NSDictionary = [
        "imageURL": "hello",
        "imageDescription": "Blue Toad",
        "imageName": "Toad"
    ]

    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main",
            bundle: NSBundle.mainBundle())
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        imageController = navigationController.topViewController as! ImageCollectionVC
        
        UIApplication.sharedApplication().keyWindow!.rootViewController = imageController
        
        // The One Weird Trick!
        let _ = navigationController.view
        let _ = imageController.view

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGenericReturnsData() {
        let url = "https://hinge-homework.s3.amazonaws.com/client/services/homework.json"
        let expectation = expectationWithDescription("Wait for \(url) to load.")
        var data: NSData?
        
        fetchImages.genericTaskRequest(url, completion: { (result) -> Void in
            data = result
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssertNotNil(data)
    }

    
    func testImageModelAddedAndConfirmed() {
        weak var asyncExpectation = expectationWithDescription("addedNewModel")
        let expectedModel = ImageModel(data: firstMock)
        let secondModel = ImageModel(data: secondMock)
        var actualModel:ImageModel!
        var gotFirst = false
        fetchImages.imageModelLoader { (result) -> Void in
            actualModel = result[0]
            if let asyncExpectation = asyncExpectation{
                if(!gotFirst){
                    asyncExpectation.fulfill()
                    gotFirst = true
                }
            }
        }
        self.waitForExpectationsWithTimeout(5) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssertEqual(actualModel.imageURL, expectedModel.imageURL,"this is the correct image model")
            XCTAssertNotEqual(actualModel.imageURL, secondModel.imageURL,"this is the wrong image model")

        }
    }
    
    func testBrokenURL(){
        let thirdModel = ImageModel(data:thirdMock)
        let secondModel = ImageModel(data:secondMock)
        fetchImages.checkIfExists(thirdModel.imageURL) { (result, error) -> () in
            XCTAssertEqual(false, result,"this image link is broken")
        }
        fetchImages.checkIfExists(secondModel.imageURL) { (result, error) -> () in
            XCTAssertEqual(true, result,"this image link is working")
        }
    }
    
    func testAddingModel(){
        let thirdModel = ImageModel(data:thirdMock)
        imageModelArray.append(thirdModel)
        XCTAssertEqual(imageModelArray.count, 1)
        XCTAssertEqual(imageModelArray[0].imageURL,"hello")
        XCTAssertEqual(imageModelArray[0].imageName,"Toad")
        XCTAssertEqual(imageModelArray[0].imageDescription,"Blue Toad")
    }

    func testCheckingModel(){
        let firstModel = ImageModel(data:firstMock)
        imageModelArray.append(firstModel)
        XCTAssertEqual(imageModelArray.count, 1)
        XCTAssertEqual(imageModelArray[0],firstModel,"this image model was correctly added to the array")
    }
    
    func testArrayElements() {
        XCTAssertEqual(imageModelArray.count, 0, "Array should have length 0")
        XCTAssertEqual(imageModelArray.isEmpty, true, "Array should be empty")
        
        let firstModel = ImageModel(data:firstMock)
        imageModelArray.append(firstModel)
        XCTAssertEqual(imageModelArray.count, 1, "Array should have length 1")
        XCTAssertEqual(imageModelArray.isEmpty, false, "Array should not be empty")
        
        let secondModel = ImageModel(data:secondMock)
        imageModelArray.append(secondModel)
        XCTAssertEqual(imageModelArray.count, 2, "Array should have length 2")
        
        imageModelArray.removeFirst()
        XCTAssertEqual(imageModelArray.count, 1, "Array should have length 1")
        
        imageModelArray.removeAtIndex(0)
        XCTAssertEqual(imageModelArray.isEmpty, true, "Array should be empty")
    
    }
    
}
