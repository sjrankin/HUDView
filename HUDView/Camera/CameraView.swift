//
//  CameraView.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI
import AVFoundation

/// A SwiftUI view that displays live camera feed
struct CameraView: UIViewRepresentable
{
    let cameraPosition: AVCaptureDevice.Position
    
    func makeUIView(context: Context) -> CameraPreviewView
    {
        let view = CameraPreviewView()
        view.cameraPosition = cameraPosition
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context)
    {
        if uiView.cameraPosition != cameraPosition
        {
            uiView.cameraPosition = cameraPosition
            uiView.setupCamera()
        }
    }
    
    static func dismantleUIView(_ uiView: CameraPreviewView, coordinator: ())
    {
        uiView.stopSession()
    }
}

/// UIView that manages the camera capture session and preview layer
class CameraPreviewView: UIView
{
    var cameraPosition: AVCaptureDevice.Position = .back
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "com.hudview.camera.session")
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupCamera()
        setupOrientationObserver()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        setupCamera()
        setupOrientationObserver()
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        updateVideoOrientation()
    }
    
    private func setupOrientationObserver()
    {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func orientationDidChange()
    {
        DispatchQueue.main.async
        {
            self.updateVideoOrientation()
        }
    }
    
    private func updateVideoOrientation()
    {
        guard let connection = previewLayer?.connection else
        {
            return
        }
        
        // Get the current interface orientation from the window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else
        {
            return
        }
        
        let interfaceOrientation = windowScene.interfaceOrientation
        
        // Map interface orientation to video orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch interfaceOrientation
        {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeLeft
        case .landscapeRight:
            videoOrientation = .landscapeRight
        case .unknown:
            videoOrientation = .portrait
        @unknown default:
            videoOrientation = .portrait
        }
        
        connection.videoOrientation = videoOrientation
    }
    
    func setupCamera()
    {
        sessionQueue.async {
            [weak self] in
            guard let self = self else
            {
                return
            }
            
            // Stop existing session if any
            self.captureSession?.stopRunning()
            
            // Create new capture session
            let session = AVCaptureSession()
            session.beginConfiguration()
            session.sessionPreset = .high
            
            // Remove old inputs
            session.inputs.forEach { session.removeInput($0) }
            
            // Get camera device
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: self.cameraPosition) else
            {
                print("Failed to get camera device")
                session.commitConfiguration()
                return
            }
            
            do
            {
                // Create input
                let input = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(input)
                {
                    session.addInput(input)
                }
                
                session.commitConfiguration()
                
                // Create preview layer on main thread
                DispatchQueue.main.async
                {
                    // Remove old preview layer if exists
                    self.previewLayer?.removeFromSuperlayer()
                    
                    let preview = AVCaptureVideoPreviewLayer(session: session)
                    preview.videoGravity = .resizeAspectFill
                    preview.frame = self.bounds
                    
                    // Add new preview layer
                    self.layer.addSublayer(preview)
                    
                    self.previewLayer = preview
                    self.captureSession = session
                    
                    // Set initial video orientation to match current device orientation
                    self.updateVideoOrientation()
                    
                    // Start session on background queue
                    self.sessionQueue.async {
                        session.startRunning()
                    }
                }
                
            }
            catch
            {
                print("Failed to setup camera: \(error.localizedDescription)")
                session.commitConfiguration()
            }
        }
    }
    
    func stopSession()
    {
        sessionQueue.async {
            [weak self] in
            self?.captureSession?.stopRunning()
            
            DispatchQueue.main.async
            {
                self?.previewLayer?.removeFromSuperlayer()
                self?.captureSession = nil
                self?.previewLayer = nil
            }
        }
    }
}
