//
//  CameraService.swift
//  Runner
//
//  Created by Arthur Nácar on 05.03.2023.
//

import Foundation
import AVFoundation

//  MARK: Class Camera Service, handles setup of AVFoundation needed for a basic camera app.
public struct Photo: Identifiable, Equatable {
//    The ID of the captured photo
    public var id: String
//    Data representation of the captured photo
    public var originalData: Data
    
    public init(id: String = UUID().uuidString, originalData: Data) {
        self.id = id
        self.originalData = originalData
    }
}


extension Photo {
    public var compressedData: Data? {
        ImageResizer(targetWidth: 800).resize(data: originalData)?.jpegData(compressionQuality: 0.5)
    }
    public var thumbnailData: Data? {
        ImageResizer(targetWidth: 100).resize(data: originalData)?.jpegData(compressionQuality: 0.5)
    }
    public var thumbnailImage: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    public var image: UIImage? {
        guard let data = compressedData else { return nil }
        return UIImage(data: data)
    }
}

public class CameraService {
    typealias PhotoCaptureSessionID = String
    
    //    MARK: Observed Properties UI must react to
    @Published public var flashMode: AVCaptureDevice.FlashMode = .off
    @Published public var shouldShowAlertView = false
    @Published public var shouldShowSpinner = false
    @Published public var willCapturePhoto = false
    @Published public var isCameraButtonDisabled = true
    @Published public var isCameraUnavailable = true
    @Published public var photo: Photo?
    
    // MARK: Session Management Properties
    public let session = AVCaptureSession()
    var isSessionRunning = false
    var isConfigured = false
    var setupResult: SessionSetupResult = .success
    private let sessionQueue = DispatchQueue(label: "session queue")
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    // MARK: Device Configuration Properties
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    
    // MARK: Capturing Photos
    private let photoOutput = AVCapturePhotoOutput()
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    // MARK: KVO and Notifications Properties
    private var keyValueObservations = [NSKeyValueObservation]()
    
    public func configure() {
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    //MARK: Checks for user's permisions
    public func checkForPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                break
            case .notDetermined:
                sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                    if !granted {
                        self.setupResult = .notAuthorized
                    }
                    self.sessionQueue.resume()
                })
                
            default:
                setupResult = .notAuthorized
                    self.shouldShowAlertView = true
                    self.isCameraUnavailable = true
                    self.isCameraButtonDisabled = true
                }
        }
    
    //  MARK: Session Management
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo

        setupAVInput()
        setupAVOutput()
        
        session.commitConfiguration()
        self.isConfigured = true
        self.start()
    }
    
    private func setupAVInput(){
            var defaultVideoDevice: AVCaptureDevice?
            if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
    }
    
    private func setupAVOutput(){
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
    }
    
    //  MARK: Device Configuration
    public func changeCamera() {
        DispatchQueue.main.async {
            self.isCameraButtonDisabled = true
        }
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
                case .unspecified, .front:
                    preferredPosition = .back
                    preferredDeviceType = .builtInWideAngleCamera
                case .back:
                    preferredPosition = .front
                    preferredDeviceType = .builtInWideAngleCamera
                @unknown default:
                    print("Unknown capture position. Defaulting to back, dual-camera.")
                    preferredPosition = .back
                    preferredDeviceType = .builtInWideAngleCamera
            }
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    
                    if let connection = self.photoOutput.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    self.photoOutput.maxPhotoQualityPrioritization = .quality
                    
                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                //                MARK: Here enable capture button due to successfull setup
                self.isCameraButtonDisabled = false
            }
        }
    }
    
    public func focus(at focusPoint: CGPoint){
        //        let focusPoint = self.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .continuousAutoExposure
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    /// - Tag: Stop capture session
    
    public func stop(completion: (() -> ())? = nil) {
        sessionQueue.async {
            if self.isSessionRunning {
                if self.setupResult == .success {
                    self.session.stopRunning()
                    self.isSessionRunning = self.session.isRunning
                    
                    if !self.session.isRunning {
                        DispatchQueue.main.async {
                            self.isCameraButtonDisabled = true
                            self.isCameraUnavailable = true
                            completion?()
                        }
                    }
                }
            }
        }
    }
    
    public func start() {
        //        We use our capture session queue to ensure our UI runs smoothly on the main thread.
        sessionQueue.async {
            if !self.isSessionRunning && self.isConfigured {
                switch self.setupResult {
                    case .success:
                        self.session.startRunning()
                        self.isSessionRunning = self.session.isRunning
                        
                        if self.session.isRunning {
                            DispatchQueue.main.async {
                                self.isCameraButtonDisabled = false
                                self.isCameraUnavailable = false
                            }
                        }
                        
                    case .configurationFailed, .notAuthorized:
                        print("Application not authorized to use camera")
                        
                        DispatchQueue.main.async {
                            self.shouldShowAlertView = true
                            self.isCameraButtonDisabled = true
                            self.isCameraUnavailable = true
                        }
                }
            }
        }
    }
    
    public func set(zoom: CGFloat){
        let factor = zoom < 1 ? 1 : zoom
        let device = self.videoDeviceInput.device
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //    MARK: Capture Photo
    public func capturePhoto() {
        if self.setupResult != .configurationFailed {
            self.isCameraButtonDisabled = true
            
            sessionQueue.async {
                if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                    photoOutputConnection.videoOrientation = .portrait
                }
                var photoSettings = AVCapturePhotoSettings()
                
                // Capture HEIF photos when supported. Enable according to user settings and high-resolution photos.
                if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                }
                
                // Sets the flash option for this capture.
                if self.videoDeviceInput.device.isFlashAvailable {
                    photoSettings.flashMode = self.flashMode
                }
                
                photoSettings.isHighResolutionPhotoEnabled = true
                
                // Sets the preview thumbnail pixel format
                if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                    photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
                }
                
                photoSettings.photoQualityPrioritization = .quality
                
                let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: { [weak self] in
                    // Tells the UI to flash the screen to signal that SwiftCamera took a photo.
                    DispatchQueue.main.async {
                        self?.willCapturePhoto = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self?.willCapturePhoto = false
                    }
                    
                }, completionHandler: { [weak self] (photoCaptureProcessor) in
                    // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                    if let data = photoCaptureProcessor.photoData {
                        self?.photo = Photo(originalData: data)
                        print("passing photo")
                    } else {
                        print("No photo data")
                    }
                    
                    self?.isCameraButtonDisabled = false
                    
                    self?.sessionQueue.async {
                        self?.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                    }
                }, photoProcessingHandler: { [weak self] animate in
                    // Animates a spinner while photo is processing
                    if animate {
                        self?.shouldShowSpinner = true
                    } else {
                        self?.shouldShowSpinner = false
                    }
                })
                
                // The photo output holds a weak reference to the photo capture delegate and stores it in an array to maintain a strong reference.
                self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
                self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            }
        }
    }
}

extension CameraService {
    enum LivePhotoMode {
        case on
        case off
    }
    
    enum DepthDataDeliveryMode {
        case on
        case off
    }
    
    enum PortraitEffectsMatteDeliveryMode {
        case on
        case off
    }
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    enum CaptureMode: Int {
        case photo = 0
        case movie = 1
    }
}
