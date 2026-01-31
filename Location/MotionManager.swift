//
//  MotionManager.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/31/26.
//

import CoreMotion
import SwiftUI

/// Manages device motion and attitude tracking
@MainActor
@Observable
class MotionManager {
    private let motionManager = CMMotionManager()
    
    var pitch: Double = 0 // Rotation around X-axis (looking up/down)
    var roll: Double = 0  // Rotation around Y-axis (tilting left/right)
    var yaw: Double = 0   // Rotation around Z-axis (compass heading)
    
    var isAvailable: Bool {
        motionManager.isDeviceMotionAvailable
    }
    
    /// Start tracking device motion
    func startUpdating() {
        guard isAvailable else {
            print("⚠️ Device motion not available")
            return
        }
        
        print("✅ Starting device motion updates")
        
        // Use reference frame that accounts for Earth's gravity and magnetic field
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
        
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("❌ Motion update error: \(error.localizedDescription)")
                }
                return
            }
            
            Task { @MainActor in
                // Get raw pitch in radians, convert to degrees
                let rawPitch = motion.attitude.pitch * 180.0 / .pi
                let rawRoll = motion.attitude.roll * 180.0 / .pi
                
                // Adjust pitch to be horizon-relative:
                // Raw pitch when level = ~90°
                // We want: 0° = level, positive = up, negative = down
                self.pitch = 90.0 - rawPitch
                self.roll = rawRoll
                self.yaw = motion.attitude.yaw * 180.0 / .pi
                
                // Debug: Print to understand the coordinate system
                print("📐 Raw: \(String(format: "%.1f", rawPitch))° → Adjusted: \(String(format: "%.1f", self.pitch))°")
            }
        }
    }
    
    /// Stop tracking device motion
    func stopUpdating() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    /// Get pitch in degrees (positive = looking up, negative = looking down)
    var pitchDegrees: Double {
        pitch
    }
    
    /// Get roll in degrees (positive = tilting right, negative = tilting left)
    var rollDegrees: Double {
        roll
    }
}
