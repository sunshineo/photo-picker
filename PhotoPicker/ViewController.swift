//
//  ViewController.swift
//  PhotoPicker
//
//  Created by Russell Austin on 1/23/15.
//  Copyright (c) 2015 Russell Austin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var images = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        
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
                    self.images.addObject(image2)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView?.reloadData()
                    })
                    
                }
            })
        }
    }
    
    @IBAction func didPressTakeAnother(sender: AnyObject) {
        captureSession!.startRunning()
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.imageView!.image = images[indexPath.row] as! UIImage
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            self.images.removeObjectAtIndex(indexPath.row)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView?.reloadData()
            })
        }
    }
    
    override func prepareForSegue(segue:(UIStoryboardSegue!), sender:AnyObject!) {
        if (segue.identifier == "viewDish") {
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow!
            let image:UIImage = self.images[indexPath.row] as! UIImage
            let dishDetailsController = segue.destinationViewController as! DishDetailsViewController
            dishDetailsController.image = image
        }
    }

    @IBAction func startEdit(sender: AnyObject) {
        self.tableView.editing = !self.tableView.editing
        if self.tableView.editing {
            editButton.title = "Done"
        }
        else {
            editButton.title = "Edit"
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true}
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = images[fromIndexPath.row]
        images.removeObjectAtIndex(fromIndexPath.row)
        images.insertObject(itemToMove, atIndex: toIndexPath.row)
    }
    
    @IBOutlet weak var editButton: UIBarButtonItem!
}

