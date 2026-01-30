//
//  HUDSettings.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import Foundation
import AVFoundation

/// Manages persistent storage of HUD settings using UserDefaults
@Observable
class HUDSettings {
    static let shared = HUDSettings()
    
    private enum Keys {
        static let selectedCamera = "hudSettings.selectedCamera"
        static let showPOIList = "hudSettings.showPOIList"
        static let showCompass = "hudSettings.showCompass"
        static let showHorizon = "hudSettings.showHorizon"
        static let selectedPOITypes = "hudSettings.selectedPOITypes"
        static let maxPOIDistance = "hudSettings.maxPOIDistance"
        static let maxListDistance = "hudSettings.maxListDistance"
    }
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Settings Properties
    
    var selectedCamera: AVCaptureDevice.Position {
        get {
            let rawValue = defaults.integer(forKey: Keys.selectedCamera)
            // If never set, defaults to 0 which is .unspecified, so we use .back
            return rawValue == 0 ? .back : AVCaptureDevice.Position(rawValue: rawValue) ?? .back
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.selectedCamera)
        }
    }
    
    var showPOIList: Bool {
        get {
            // Default to false if never set
            defaults.object(forKey: Keys.showPOIList) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: Keys.showPOIList)
        }
    }
    
    var showCompass: Bool {
        get {
            // Default to true if never set
            defaults.object(forKey: Keys.showCompass) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.showCompass)
        }
    }
    
    var showHorizon: Bool {
        get {
            // Default to true if never set
            defaults.object(forKey: Keys.showHorizon) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.showHorizon)
        }
    }
    
    var selectedPOITypes: Set<POIType> {
        get {
            if let rawValues = defaults.array(forKey: Keys.selectedPOITypes) as? [String] {
                let types = rawValues.compactMap { POIType(rawValue: $0) }
                return Set(types)
            }
            // Default to all types if never set
            return Set(POIType.allCases)
        }
        set {
            let rawValues = newValue.map { $0.rawValue }
            defaults.set(rawValues, forKey: Keys.selectedPOITypes)
        }
    }
    
    var maxPOIDistance: Double {
        get {
            let value = defaults.double(forKey: Keys.maxPOIDistance)
            // Default to 100km if never set
            return value == 0 ? 100_000 : value
        }
        set {
            defaults.set(newValue, forKey: Keys.maxPOIDistance)
        }
    }
    
    var maxListDistance: Double {
        get {
            let value = defaults.double(forKey: Keys.maxListDistance)
            // Default to 50km if never set
            return value == 0 ? 50_000 : value
        }
        set {
            defaults.set(newValue, forKey: Keys.maxListDistance)
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Private init to enforce singleton pattern
    }
    
    // MARK: - Convenience Methods
    
    /// Reset all settings to their default values
    func resetToDefaults() {
        selectedCamera = .back
        showPOIList = false
        showCompass = true
        showHorizon = true
        selectedPOITypes = Set(POIType.allCases)
        maxPOIDistance = 100_000
        maxListDistance = 50_000
    }
}
