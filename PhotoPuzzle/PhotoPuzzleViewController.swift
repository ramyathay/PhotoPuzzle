//
//  ViewController.swift
//  PhotoPuzzle
//
//  Created by Ramyatha Yugendernath on 1/26/16.
//  Copyright © 2016 Ramyatha Yugendernath. All rights reserved.
//

import UIKit

class PhotoPuzzleViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var previousUserGameCount: String = ""
    var imageNameDescription: String = ""
    //Holds names of all the images
    var croppedImagesArray: [UIImage] = []   //Holds the original Image cropped Instances
    var shuffledImagesDict = [Int: Int]()   //Associates the image tag with the image in croppedImagesArray. This is to know which image resides in which image tag
    var handleSwipedImagesArray: [UIImage] = []   //For handling swiped Images position so that croppedImages Array remains altered and will be useful for checking against game end status
    var timer =  NSTimer()
    var countTime = 0
    var minutes = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        runTimerLabel.textAlignment = .Center
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenScale: CGFloat = UIScreen.mainScreen().scale
        let imageSize = CGSize(width: screenSize.width * screenScale, height: screenSize.height * screenScale)
        
//        if previousUserGameCount != "" {
//            imageNameLabel.hidden = false
//            imageNameLabel.text = "The Previous User's game play time was \(previousUserGameCount) secs"
//        }
//        else {
//            imageNameLabel.hidden = true
//        }
        
        //Generating a random image from collection of images
        //let selectImageName = Int(arc4random_uniform(UInt32(allImageNamesArray.count)))
        
        self.view.backgroundColor = UIColor.lightGrayColor()
        //let actualImage = UIImage(named: allImageNamesArray[selectImageName])
        
        let url = NSURL(string: "https://source.unsplash.com/random")
        let data = NSData(contentsOfURL: url!)
        let actualImage = UIImage(data: data!)
        UIGraphicsBeginImageContext(imageSize)
        actualImage?.drawInRect((CGRect(origin: CGPointZero, size: imageSize)))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        print("Image size is",actualImage?.size.height,actualImage?.size.width)

        imageNameDescription = "Congratulations you have completed the puzzle"
        
        var randomNums = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
            //Generating 16 cropped instances of the actualImage
            var w:Int , h: Int
            for h = 0 ; h < 4 ; h++ {
                for w = 0 ; w < 4 ; w++ {
                    let imgWidth: CGFloat = scaledImage!.size.width/4;
                    let imgHeight: CGFloat  = scaledImage!.size.height/4;
                    let imgFrame: CGRect = CGRectMake(CGFloat((scaledImage!.size.width / 4) * CGFloat(w)), CGFloat((scaledImage!.size.height / 4) * CGFloat(h) ), imgWidth, imgHeight)
                    let imgInRect: CGImageRef = CGImageCreateWithImageInRect(scaledImage!.CGImage, imgFrame)!
                    let croppedImage: UIImage = UIImage(CGImage: imgInRect)
                    croppedImagesArray.append(croppedImage)
                    print("Per image size is",scaledImage.size.width, scaledImage.size.height)
                }
            }
        
            for var k = 0; k < croppedImagesArray.count ; k++ {
            
                //Creates a random number from 0 to croppedImagesArray.count - 1 to create a shuffled images display
                let randomNumber = Int(arc4random_uniform(UInt32(randomNums.count)))
            
                let randomImageNumber = randomNums[randomNumber]
                randomNums.removeAtIndex(randomNumber)
            
                if let img = self.view.viewWithTag(k + 1) as! UIImageView! {
                    img.image = croppedImagesArray[randomImageNumber]
                    img.layer.borderWidth = 1
                    img.layer.borderColor = UIColor.whiteColor().CGColor
                    img.contentMode = .ScaleToFill
                    shuffledImagesDict[k + 1] = randomImageNumber
                    print("Cropped image",img.frame.height,img.frame.width,img.image?.size.height,img.image?.size.width)
                    
                    let directions: [UISwipeGestureRecognizerDirection] = [.Right, .Left, .Up, .Down]
                    for direction in directions {
                        let swipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
                        swipe.direction = direction
                        // we use our delegate
                        swipe.delegate = self
                        // allow for user interaction
                        img.userInteractionEnabled = true
                        // add tap as a gestureRecognizer to tapView
                        img.addGestureRecognizer(swipe)
                    }
                }
            }
            handleSwipedImagesArray = croppedImagesArray
        //Timer to indicate the start of game
        timer = NSTimer(timeInterval: 1.0, target: self, selector: "countUp", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var imageNameLabel: UILabel!
    
    @IBOutlet var croppedUIImageLabel: [UIImageView]!

    @IBOutlet weak var runTimerLabel: UILabel!
    
    @IBAction func resetGameButtonPressed(sender: UIButton) {
        print("Reset button pressed")
        resetOperation()
    }
    
    @IBAction func finishGameButtonPressed(sender: UIButton) {
        let Title: String = "The Photo Puzzle"
        let Message: String = "Game still not over would you like to continue?"
        var isGameOver = false
        for var j = 0 ; j < handleSwipedImagesArray.count; j++ {
            if handleSwipedImagesArray[shuffledImagesDict[j + 1]!] == croppedImagesArray[j] {
                print("Both images are equal at index \(j)")
                isGameOver = true
            }
            else {
                print("Game not over")
                isGameOver = false
                
                //Creating custom color for UIAlertView TitleString and message body
                let TitleString = NSAttributedString(string: Title, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : UIColor.whiteColor()])
                let MessageString = NSAttributedString(string: Message, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : UIColor.whiteColor()])
                
                // create the alert
                let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertControllerStyle.Alert)
                //adding Custom animations to the UIAlertController
                //Adding colors to the UIAlertViewController's text title and message
                alert.setValue(TitleString, forKey: "attributedTitle")
                alert.setValue(MessageString, forKey: "attributedMessage")
                
                //adding animations to the UIViewController dialog box
                let subview = alert.view.subviews.first! as UIView
                let alertContentView = subview.subviews.first! as UIView
                alertContentView.backgroundColor = UIColor.purpleColor()
                alertContentView.layer.cornerRadius = 10
                alertContentView.alpha = 1
                alertContentView.layer.borderWidth = 1
                alertContentView.layer.borderColor = UIColor.blackColor().CGColor
                alert.view.tintColor = UIColor.whiteColor()
                
                // add the actions (buttons) - Continue playing
                alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: nil))
                
                //alert for stopping the game
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {action in
                        self.resetOperation()
                }))
                
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        if isGameOver {
            // create the alert
            let alert = UIAlertController(title: "The Photo Puzzle", message: imageNameDescription, preferredStyle: UIAlertControllerStyle.Alert)
            //adding Custom animations to the UIAlertController
            let subview = alert.view.subviews.first! as UIView
            let alertContentView = subview.subviews.first! as UIView
            alertContentView.backgroundColor = UIColor.cyanColor()
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {action in
               self.resetOperation()
            }))
           
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
       //Current Image
        let img = self.view.viewWithTag(sender.view!.tag) as! UIImageView!

        //For Right Swipe
        if sender.direction.rawValue == 1 {
            img.image = self.handleSwipedImagesArray[self.shuffledImagesDict[sender.view!.tag + 1]!]
            //Adding Animations to the Swiped Image
//            UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseOut, animations: {
//                img.alpha = 0.1
//                img.image = self.handleSwipedImagesArray[self.shuffledImagesDict[sender.view!.tag + 1]!]
//                }, completion: { (finished: Bool) -> Void in
//                    UIView.animateWithDuration(0.06, animations: { () -> Void in
//                        img.alpha = 1.0
//                    })
//            })
            
            //Changing Swapped Image to Swiped Image
            let swapImg = self.view.viewWithTag(sender.view!.tag + 1) as! UIImageView!
            //Adding Animations to the Swiped Image
            UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseOut, animations: {
                swapImg.alpha = 0.1
                swapImg.image = self.handleSwipedImagesArray[self.shuffledImagesDict[sender.view!.tag]!]
                }, completion: { (finished: Bool) -> Void in
                    UIView.animateWithDuration(0.06, animations: { () -> Void in
                        swapImg.alpha = 1.0
                    })
            })
            //swapImg.image = self.handleSwipedImagesArray[self.shuffledImagesDict[sender.view!.tag]!]
        
          
            (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!],handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag + 1]!]) = (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag + 1]!] , handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!])
            print("Right swipe")
            
        } //For Left swipe
        else if sender.direction.rawValue == 2 {
            img.image = handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag - 1]!]
            
            let swapImg = self.view.viewWithTag(sender.view!.tag - 1) as! UIImageView!
            UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseOut, animations: {
                swapImg.alpha = 0.1
                swapImg.image = self.handleSwipedImagesArray[self.shuffledImagesDict[sender.view!.tag]!]
                }, completion: { (finished: Bool) -> Void in
                    UIView.animateWithDuration(0.06, animations: { () -> Void in
                        swapImg.alpha = 1.0
                    })
            })
            
            
            (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!],handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag - 1]!]) = (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag - 1]!] , handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!])
            
            print("Left swipe")
        }// For Top swipe
        else if sender.direction.rawValue == 4 {
            img.image = handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag - 4]!]
            
            let swapImg = self.view.viewWithTag(sender.view!.tag - 4) as! UIImageView!
            UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseOut, animations: {
                swapImg.alpha = 0.1
                swapImg.image = self.handleSwipedImagesArray[self.shuffledImagesDict[sender.view!.tag]!]
                }, completion: { (finished: Bool) -> Void in
                    UIView.animateWithDuration(0.06, animations: { () -> Void in
                        swapImg.alpha = 1.0
                    })
            })
            
            (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!],handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag - 4]!]) = (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag - 4]!] , handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!])
            
            print("Top swipe")
        }// For Bottom swipe
        else if sender.direction.rawValue == 8 {
            img.image = handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag + 4]!]
            
            let swapImg = self.view.viewWithTag(sender.view!.tag + 4) as! UIImageView!
            UIView.animateWithDuration(0.6, delay: 0, options: .CurveEaseOut, animations: {
                swapImg.alpha = 0.1
                swapImg.image = self.handleSwipedImagesArray[self.shuffledImagesDict[sender.view!.tag]!]
                }, completion: { (finished: Bool) -> Void in
                    UIView.animateWithDuration(0.06, animations: { () -> Void in
                        swapImg.alpha = 1.0
                    })
            })
            
            (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!],handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag + 4]!]) = (handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag + 4]!] , handleSwipedImagesArray[shuffledImagesDict[sender.view!.tag]!])
            
            print("Bottom swipe")
        }
    }
    
    func countUp() {
        countTime += 1
        if countTime > 60 {
            minutes += 1
            countTime = 0
        }
        updateLabelForDisplay()
    }
    
    func updateLabelForDisplay() {
        //print("increasing count by 1")
        runTimerLabel.text = String(minutes) + ":" + String(countTime)
    }
    func resetOperation() {
        print("reset Opertaion to be executed")
        timer.invalidate()
        previousUserGameCount = String(minutes) + ":" + String(countTime)
        countTime = 0
        minutes = 0
        updateLabelForDisplay()
        croppedImagesArray = []
        shuffledImagesDict = [:]
        handleSwipedImagesArray = []
        //imageNameLabel.text = ""
        viewDidLoad()
    }
}

//let imageURL = NSURL(fileURLWithPath: "/Users/ramyathay/Desktop/ironManFlying.jpg")
//let actualImage = UIImageView(image: imagefromBundle)
//if let imageData = NSData(contentsOfURL: imageURL) {
//let actualImage: UIImage = UIImage(data: imageData)!

//now you need a tap gesture recognizer
//note that target and action point to what happens when the action is recognized.
//let tapRecognizer = UIPanGestureRecognizer(target: self, action: Selector("imageTapped:"))
//Add the recognizer to your view.
//img.addGestureRecognizer(tapRecognizer)

//        UIView.animateWithDuration(0.35, animations: {
//            mainscreenCard.frame = CGRectMake(mainscreenCard.frame.origin.x,
//                self.view.frame.height,
//                mainscreenCard.frame.size.width,
//                mainscreenCard.frame.size.height)
//        })

//func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
//    //tappedImageView will be the image view that was tapped ,dismiss it, animate it off screen, whatever.
//    let tappedImageView = gestureRecognizer.view!
//    tappedImageView.removeFromSuperview()
//}
//
//func addSwipe() {
//    let directions: [UISwipeGestureRecognizerDirection] = [.Right, .Left, .Up, .Down]
//    for direction in directions {
//        let gesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
//        gesture.direction = direction
//        self.view.addGestureRecognizer(gesture)
//    }
//}
//
