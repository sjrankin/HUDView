//
//  CameraManager.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import AVFoundation
import SwiftUI

/// Manages camera permissions and availability
@MainActor
@Observable
class CameraManager {
    var authorizationStatus: AVAuthorizationStatus = .notDetermined
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }
    
    init() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// Request camera access permission
    func requestPermission() async {
        let _ = await AVCaptureDevice.requestAccess(for: .video)
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// Check if device has cameras available
    func hasCameras() -> Bool {
        return !AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        ).devices.isEmpty
    }
}
