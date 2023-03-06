//
//  CameraViewModel.swift
//  Runner
//
//  Created by Arthur Nácar on 05.03.2023.
//

import Foundation
import AVFoundation

class CameraViewModel {
    private let service = CameraService()
    var session: AVCaptureSession
    
    init() {
        self.session = service.session
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
        service.start()
    }
    
    func capturePhoto() {
        //service.capturePhoto()
    }
    
    func startVideoRecording() {
        //service.startVideoRecording()
    }
    
    func stopVideoRecording() {
//        service.stopVideoRecording()
    }
    
    func captureAction() {
//        service.captureAction()
    }
    
    func flipCamera() {
//        service.flipCamera()
    }
    
    func changeCameraLens() {
        
    }
    
    func zoom(with factor: CGFloat) {
//        service.set(zoom: factor)
    }
    
    func switchFlash() {
//        service.flashMode = service.flashMode == .on ? .off : .on
    }
    
}
