//
//  GalleryViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 09/06/22.
//

import UIKit
import AVFoundation


// To Be Completed - Part Of Assignment Extra Functionality
class GalleryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.openCameraView()

        // Do any additional setup after loading the view.
    }
    

    func openCameraView(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            self.setupCaptureSession()
            
        case .denied:
            // Case Denied
            print("Denied")
        
        case .restricted:
            // Restricted
            print("Restricted")
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){(granted) in
                // Access Granted
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                }
                else {
                    // No ACCESS granted
                }
            }
            
        default:
            print("Some Error")
            
        }
        
    }
    
    func setupCaptureSession(){
        let captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(for: .video){
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input){
                    captureSession.addInput(input)
                }
            }
            catch let error {
                print("Failed to load input device")
            }
            
           let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
            
            captureSession.startRunning()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
