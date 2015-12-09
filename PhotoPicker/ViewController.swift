//
//  ViewController.swift
//  PhotoPicker
//
//  Created by Russell Austin on 1/23/15.
//  Copyright (c) 2015 Russell Austin. All rights reserved.
//

import UIKit
import AVFoundation
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }

    @IBAction func didPressTakePhoto(sender: UIButton) {
        let previewWidth = previewLayer?.bounds.width
        print(previewWidth)
        let previewHeight = previewLayer?.bounds.height
        print(previewHeight)
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    let imageWidth = image.size.width
                    print(imageWidth)
                    let imageHeight = image.size.height
                    print (imageHeight)
                    
                    // Calculate desired height. We want the whole width
                    let desiredHeight = (imageWidth / previewWidth!) * previewHeight!
                    print(desiredHeight)
                    let shiftDown = (imageHeight - desiredHeight) / 2
                    print(shiftDown)
                    
                    let rect: CGRect = CGRectMake(shiftDown, 0.0, desiredHeight, imageWidth)
                    let imageRef: CGImageRef = CGImageCreateWithImageInRect(image.CGImage, rect)!
                    let image2: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
                    print(image.imageOrientation.rawValue)
                    
                    self.capturedImage.image = image2
                    
                    // Tesseract things image2 is upside down.
                    let image3: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: UIImageOrientation.Left)
                    
                    
                    let tesseract:G8Tesseract = G8Tesseract(language:"eng")
                    //tesseract.language = "eng+ita"
                    tesseract.delegate = self
                    //tesseract.charWhitelist = "01234567890"
                    tesseract.image = image3
                    tesseract.recognize()
                    
                    NSLog("%@", tesseract.recognizedText)
                    print(tesseract.recognizedText)
                }
            })
        }
    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession!.startRunning()
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false; // return true if you need to interrupt tesseract before it finishes
    }


}

