//
//  GameViewController.swift
//  晒跑校园alpha
//
//  Created by 刘炳辰 on 14/10/28.
//  Copyright (c) 2014年 刘炳辰. All rights reserved.
//

import UIKit
import SpriteKit
import AssetsLibrary

var delayTime:CGFloat = 1.1

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            do{
                let sceneData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
                
                archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
                archiver.finishDecoding()
                return scene
            }catch{
                print(error)
                return nil
            }
            

        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var gameStartButton: UIButton!
    @IBOutlet weak var confirmButton:UIButton!
    @IBOutlet weak var clearButton:UIButton!
    @IBOutlet weak var chooseImgButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fliterSlider: UISlider!

    @IBOutlet var bgc: UIImageView!
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    
    var gameScene:SKScene?
    var context: CIContext!
    var filter: CIFilter!
    var beginImage: CIImage!
    var orientation: UIImageOrientation = .Up

    @IBAction func goBack(sender: AnyObject) {
        imageView.layer.cornerRadius = 80;
        self.loadView()
        goBackButton.hidden = true

    }
    
    //设置游戏难易程度
    @IBAction func setHardOrEasy(button:UIButton!){
        if button.titleLabel?.text == "H"{
            delayTime = 0.8
        } else if button.titleLabel?.text == "M"{
            delayTime = 1.1
        } else if button.titleLabel?.text == "L"{
            delayTime = 1.4
        }
    }
    
    @IBAction func GameStart(sender: AnyObject) {
        if let gameScene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            //scene.size = self.view.frame.size
            // Configure the view.
            //NSLog("size \(gameScene.size)");
            
            let skView = self.view as! SKView
            
            /*
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsFields = true
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            */
            gameScene.scaleMode = .AspectFill

            skView.presentScene(gameScene)
            
            gameStartButton.hidden = true
            confirmButton.hidden = true
            goBackButton.hidden = false
            fliterSlider.hidden = true
            imageView.hidden = true
            chooseImgButton.hidden = true
            clearButton.hidden = true
            easyButton.hidden = true
            hardButton.hidden = true
            middleButton.hidden = true
            bgc.hidden = true
        }

    }
    
    //读取图片
    @IBAction func loadPhoto(sender : AnyObject) {
        
        let pickerC = UIImagePickerController()
        
        pickerC.delegate = self
        
        //let popover = UIPopoverController(contentViewController: pickerC)
        //popover.presentPopoverFromRect(self.chooseImgButton.frame, inView: self.view, permittedArrowDirections: .Up, animated: true)
        
        self.presentViewController(pickerC, animated: true, completion: nil)
        
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil);
        let gotImage = image
        beginImage = CIImage(image: gotImage)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        orientation = gotImage.imageOrientation
        self.amountSliderValueChanged(fliterSlider)
    }

    
    //保存图片
    @IBAction func savePhoto(sender: AnyObject) {
        let tmpImage = imageView.image
        
        let imageFrame:CGSize = CGSizeMake(100, 100)
        let image = scaleToSize(tmpImage!, size: imageFrame)
        let filePath = NSHomeDirectory() + "/Documents/head.png"
        //println(filePath)
        UIImageJPEGRepresentation(image, 1.0)!.writeToFile(filePath, atomically: true)
    }
    
    //剪裁图片使其以正好的大小显示在游戏里
    func scaleToSize(img:UIImage , size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size,false,1.0)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        _ = UIGraphicsGetCurrentContext()
        let rect = CGRectMake(0, 0, size.width, size.height)

        img.drawInRect(rect)
        
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg
    }
    
    @IBAction func clearPhoto(sender:AnyObject) {
        let filePath = NSHomeDirectory() + "/Documents/head.png"
        let fileManager = NSFileManager()
        
        do{
            try fileManager.removeItemAtPath(filePath)
        }catch{
            print(error)
        }
    }
    //调整滤镜的效果
    @IBAction func amountSliderValueChanged(sender: UISlider) {
        
        
        
        let sliderValue = sender.value
        
        
        filter.setValue(sliderValue, forKey: kCIInputIntensityKey)
        
        let outputImage = filter.outputImage
        
        let cgimg = context.createCGImage(outputImage!, fromRect: outputImage!.extent)
        
        
        let newImage = UIImage(CGImage: cgimg, scale:1, orientation:orientation)
        
        self.imageView.image = newImage
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        goBackButton.hidden = true
        
        let fileURL = NSBundle.mainBundle().URLForResource("楪祈1", withExtension: "jpg")
        beginImage = CIImage(contentsOfURL: fileURL!)
        
        filter = CIFilter(name: "CISepiaTone")
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setValue(0.5, forKey: kCIInputIntensityKey)
        
        context = CIContext(options:nil)
        let cgimg = context.createCGImage(filter.outputImage!,fromRect:filter.outputImage!.extent)
        let newImage = UIImage(CGImage:cgimg)
        self.imageView.image = newImage
        imageView.layer.cornerRadius = 80;
        imageView.layer.masksToBounds = true;

    }

    override func viewWillAppear(animated: Bool) {
        imageView.layer.cornerRadius = 80;
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    //调整游戏页面的方向
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.Landscape
        } else {
            return UIInterfaceOrientationMask.Landscape
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
