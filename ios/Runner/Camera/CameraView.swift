//
//  CameraView.swift
//  Runner
//
//  Created by Arthur Nácar on 05.03.2023.
//

import Foundation
import Flutter
import UIKit

class FLCameraViewFactory: NSObject, FlutterPlatformViewFactory {
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLCameraView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args, binaryMessenger: nil)
    }
}

class FLCameraView: NSObject, FlutterPlatformView {
    private var _view: UIView
    let viewModel: CameraViewModel = CameraViewModel()

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        // iOS views can be created here
        createNativeView(view: _view)
        viewModel.configure()
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView){
        let nativeView = CameraPreviewView()
        nativeView.backgroundColor = .black
        nativeView.videoPreviewLayer.cornerRadius = 0
        nativeView.videoPreviewLayer.session = viewModel.session
        nativeView.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        _view.addSubview(nativeView)
    }
}
