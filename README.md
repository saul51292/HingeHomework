# HingeHomework
A simple Swift Image View and Gallery

## Synopsis

This application is a simple gallery and image viewer. The gallery allows a user to scroll through images loaded from a JSON file while the image viewer allows a user to see an individual image more clealy. Once in the image viewer, the image changes every 2 seconds.

## ImageModel

ImageModels are used throughout the app and consist of 3 parts:

	imageName = the name of the image
	imageURL = the url of the image
	imageDescription = the description of the image

	An ImageModel takes an NSDictionary that must have all 3 of these pieces.

## Async Image Loading

One big goal of this project was to create asyncrounous image loading without the use of third party libraries. Through the use of NSURLSession.downloadWithTask as well as dispatch_async(dispatch_get_main_queue()), the program is able to download images asyncronously. 

One extra note is the use of a download queue. Once the user opens up the app, the app immediately starts to download images. However, if a user clicks on an image, the app should download his selected image. 

With this problem in mind, I created a queue that is cleared once a user taps on an image. This makes sure that the user selected image now has additional resources to download the selected image as fast as possible.

## NSCache

All images on the app are stored in NSCache and are removed from the cache if a user elects to remove the image from within the image viewer.

## Installation

Download and run through XCode. The project should run on iPhone devices with screen sizes 4 inches and above.

## Source Used for this project

https://hinge-homework.s3.amazonaws.com/client/services/homework.json

One can change this source inside of the FetchImages file

## Tests

All tests are inside of the HingeHomeworkTests bundle

testGenericReturnsData()

Tests to make sure data is being received

testImageModelAddedAndConfirmed()

Tests to make sure imageModels are correctly added and positioned within the array

testBrokenURL()

Tests to make sure image links are not broken

testAddingModel()

Tests to make sure imageModels are added

testArrayElements()

Tests the imageModel array

