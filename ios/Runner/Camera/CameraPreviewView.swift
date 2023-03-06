//
//  CameraPreview.swift
//  Runner
//
//  Created by Arthur Nácar on 06.03.2023.
//

import SwiftUI
import AVFoundation

    class CameraPreviewView: UIView {
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
