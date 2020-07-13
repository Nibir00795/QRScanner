//
//  ViewController.swift
//  QRScanner
//
//  Created by Nibir00795 on 12/7/20.
//  Copyright © 2020 Nibir. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraContainerView: UIView!
    
    let pickerController = UIImagePickerController()
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        cameraContainerView.frame.size = CGSize(width: 270.0, height: 270.0)
        cameraContainerView.center = CGPoint(x: view.bounds.width/2, y: (view.bounds.height/2))
        self.view.addSubview(cameraContainerView)
        
        if !isReading {
            if (self.startReading()) {
            }
        }
        else {
            stopReading()
        }
        isReading = !isReading
        
        ToastView.shared.warn(cameraContainerView, txt_msg: "Only URL QR can redirect to browser", show: "hide")
        
        
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus == .denied || cameraAuthorizationStatus == .restricted {
            alertCameraAccessNeeded()
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func importImgBtnEventListener(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            pickerController.delegate = self
            pickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    
}


extension ViewController : AVCaptureMetadataOutputObjectsDelegate{
    func loadSafari(url : String){
        guard let url = URL(string: url) else { return }
        
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true, completion: nil)
    }
    
    func startReading() -> Bool {
        ToastView.shared.warn(cameraContainerView, txt_msg: "Only URL QR can redirect to browser", show: "hide")
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // Do the rest of your work...
        } catch let error as NSError {
            // Handle any errors
            print("errror....\(error)")
            return false
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = cameraContainerView.layer.bounds
        cameraContainerView.layer.addSublayer(videoPreviewLayer)
        
        
        /* Check for metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession?.startRunning()
        return true
    }
    
    @objc func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        // videoPreviewLayer.removeFromSuperlayer()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for data in metadataObjects {
            let metaData = data
            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            
            if let unwraped = transformed {
                
                if let urlString = unwraped.stringValue{
                    
                    if urlString.isValidURL{//check whether the string is URL
                        
                        isReading = false;
                        stopReading()
                        ToastView.shared.warn( cameraContainerView, txt_msg: "Only URL QR can redirect to browser", show: "hide")
                        
                        ToastView.shared.short(cameraContainerView, txt_msg: urlString)
                        let seconds = 2.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            self.loadSafari(url: urlString)
                        }
                        
                    }else {
                        
                        print("awaw")
                        ToastView.shared.warn(cameraContainerView, txt_msg: "Only URL QR can redirect to browser", show: "show")
                        
                        
                    }
                    
                }
                
                
            }
        }
    }
}
extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}



extension ViewController {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let qrcodeImg = info[.originalImage] as? UIImage {
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:qrcodeImg)!
            var qrCodeLink=""
            
            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
            if qrCodeLink=="" {
                print("nothing")
                ToastView.shared.short(cameraContainerView, txt_msg: "No QR code could be detected. Please try again")
            }else{
                print("message: \(qrCodeLink)")
                if qrCodeLink.isValidURL{//check whether the string is URL
                    
                    isReading = false;
                    self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
                    ToastView.shared.warn(cameraContainerView, txt_msg: "Only URL QR can redirect to browser", show: "hide")
                    
                    ToastView.shared.short(self.cameraContainerView, txt_msg: qrCodeLink)
                    let seconds = 2.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.loadSafari(url: qrCodeLink)
                    }
                    
                }else {
                    ToastView.shared.warn(cameraContainerView, txt_msg: "Only URL QR can redirect to browser", show: "show")
                    
                }
                
                
                
            }
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to make full use of this app.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
}



