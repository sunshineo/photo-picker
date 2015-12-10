//
//  DishDetailsController.swift
//  PhotoPicker
//
//  Created by Gordon Sun on 12/9/15.
//  Copyright © 2015 Russell Austin. All rights reserved.
//

import UIKit
import TesseractOCR

class DishDetailsViewController: UIViewController, G8TesseractDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var ocrResult: UITextField!
    
    var ocrText: String = "Parsing image"
    
    var image: UIImage! {
        didSet {
            
            // Tesseract things image is upside down.
            let imageRef: CGImageRef = image.CGImage!
            let image2: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: UIImageOrientation.Left)
            
            
            let tesseract:G8Tesseract = G8Tesseract(language:"eng")
            //tesseract.language = "eng+ita"
            tesseract.delegate = self
            //tesseract.charWhitelist = "01234567890"
            tesseract.image = image2
            tesseract.recognize()
            
            print(tesseract.recognizedText)
            ocrText = tesseract.recognizedText
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        ocrResult.text = ocrText

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false; // return true if you need to interrupt tesseract before it finishes
    }
    

}
