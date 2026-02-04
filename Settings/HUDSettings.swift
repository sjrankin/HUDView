//
//  HUDSettings.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import Foundation
import AVFoundation

/// Manages persistent storage of HUD settings using UserDefaults
@Observable class HUDSettings
{
    static let shared = HUDSettings()
    
    private enum Keys
    {
        static let selectedCamera = "hudSettings.selectedCamera"
        static let showPOIList = "hudSettings.showPOIList"
        static let showCompass = "hudSettings.showCompass"
        static let showHorizon = "hudSettings.showHorizon"
        static let selectedPOITypes = "hudSettings.selectedPOITypes"
        static let maxPOIDistance = "hudSettings.maxPOIDistance"
        static let maxListDistance = "hudSettings.maxListDistance"
        static let distanceUnit = "hudSettings.distanceUnit"
        static let visitedRoutePOIs = "hudSettings.visitedRoutePOIs"
    }
    
    /// Distance unit for display
    enum DistanceUnit: String, CaseIterable
    {
        case metric = "metric"
        case imperial = "imperial"
        
        var displayName: String
        {
            switch self
            {
                case .metric: return "Kilometers"
                case .imperial: return "Miles"
            }
        }
        
        var abbreviation: String
        {
            switch self
            {
                case .metric: return "km"
                case .imperial: return "mi"
            }
        }
        
        var smallUnit: String
        {
            switch self
            {
                case .metric: return "m"
                case .imperial: return "ft"
            }
        }
        
        /// Convert meters to the display unit
        func convert(meters: Double) -> Double
        {
            switch self
            {
                case .metric:
                    return meters / 1000.0 // Convert to kilometers
                case .imperial:
                    return meters / 1609.34 // Convert to miles
            }
        }
        
        /// Convert meters to small unit (meters or feet)
        func convertSmall(meters: Double) -> Double
        {
            switch self
            {
                case .metric:
                    return meters
                case .imperial:
                    return meters * 3.28084 // Convert to feet
            }
        }
        
        /// Format distance with appropriate unit
        func format(meters: Double) -> String
        {
            if meters < 1000
            {
                // Use small unit for distances under 1km/0.62mi
                let value = convertSmall(meters: meters)
                return String(format: "%.0f %@", value, smallUnit)
            }
            else if meters < 10000
            {
                // One decimal place for mid-range distances
                let value = convert(meters: meters)
                return String(format: "%.1f %@", value, abbreviation)
            }
            else
            {
                // No decimal places for long distances
                let value = convert(meters: meters)
                return String(format: "%.0f %@", value, abbreviation)
            }
        }
        
        /// Standard distance presets in meters
        static let distancePresets: [Double] =
        [
            1_000,      // 1 km / 0.62 mi
            5_000,      // 5 km / 3.1 mi
            10_000,     // 10 km / 6.2 mi
            25_000,     // 25 km / 15.5 mi
            50_000,     // 50 km / 31 mi
            100_000,    // 100 km / 62 mi
            200_000,    // 200 km / 124 mi
            500_000,    // 500 km / 311 mi
            1_000_000,  // 1000 km / 621 mi
            5_000_000   // 5000 km / 3107 mi
        ]
        
        /// Format preset distance for display in picker
        func formatPreset(meters: Double) -> String
        {
            let value = convert(meters: meters)
            if value < 1
            {
                // For values less than 1 unit, show in smaller unit
                return String(format: "%.0f %@", convertSmall(meters: meters), smallUnit)
            } else if value >= 1000
            {
                // For very large values, show with commas
                return String(format: "%.0f %@", value, abbreviation)
            }
            else
            {
                // Show whole numbers for most cases
                return String(format: "%.0f %@", value, abbreviation)
            }
        }
    }
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Settings Properties
    
    var selectedCamera: AVCaptureDevice.Position
    {
        get
        {
            let rawValue = defaults.integer(forKey: Keys.selectedCamera)
            // If never set, defaults to 0 which is .unspecified, so we use .back
            return rawValue == 0 ? .back : AVCaptureDevice.Position(rawValue: rawValue) ?? .back
        }
        set
        {
            defaults.set(newValue.rawValue, forKey: Keys.selectedCamera)
        }
    }
    
    var showPOIList: Bool
    {
        get
        {
            // Default to false if never set
            defaults.object(forKey: Keys.showPOIList) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: Keys.showPOIList)
        }
    }
    
    var showCompass: Bool
    {
        get
        {
            // Default to true if never set
            defaults.object(forKey: Keys.showCompass) as? Bool ?? true
        }
        set
        {
            defaults.set(newValue, forKey: Keys.showCompass)
        }
    }
    
    var showHorizon: Bool
    {
        get
        {
            // Default to true if never set
            defaults.object(forKey: Keys.showHorizon) as? Bool ?? true
        }
        set
        {
            defaults.set(newValue, forKey: Keys.showHorizon)
        }
    }
    
    var selectedPOITypes: Set<POIType>
    {
        get
        {
            if let rawValues = defaults.array(forKey: Keys.selectedPOITypes) as? [String]
            {
                let types = rawValues.compactMap { POIType(rawValue: $0) }
                return Set(types)
            }
            // Default to all types if never set
            return Set(POIType.allCases)
        }
        set
        {
            let rawValues = newValue.map { $0.rawValue }
            defaults.set(rawValues, forKey: Keys.selectedPOITypes)
        }
    }
    
    var maxPOIDistance: Double
    {
        get
        {
            let value = defaults.double(forKey: Keys.maxPOIDistance)
            // Default to 100km if never set
            return value == 0 ? 100_000 : value
        }
        set
        {
            defaults.set(newValue, forKey: Keys.maxPOIDistance)
        }
    }
    
    var maxListDistance: Double
    {
        get
        {
            let value = defaults.double(forKey: Keys.maxListDistance)
            // Default to 50km if never set
            return value == 0 ? 50_000 : value
        }
        set
        {
            defaults.set(newValue, forKey: Keys.maxListDistance)
        }
    }
    
    var distanceUnit: DistanceUnit
    {
        get
        {
            if let rawValue = defaults.string(forKey: Keys.distanceUnit),
               let unit = DistanceUnit(rawValue: rawValue)
            {
                return unit
            }
            // Default to metric
            return .metric
        }
        set
        {
            defaults.set(newValue.rawValue, forKey: Keys.distanceUnit)
        }
    }
    
    var visitedRoutePOIs: Set<String>
    {
        get
        {
            if let names = defaults.array(forKey: Keys.visitedRoutePOIs) as? [String]
            {
                return Set(names)
            }
            return []
        }
        set
        {
            defaults.set(Array(newValue), forKey: Keys.visitedRoutePOIs)
        }
    }
    
    // MARK: - Initialization
    
    private init()
    {
        // Private init to enforce singleton pattern
    }
    
    // MARK: - Convenience Methods
    
    /// Reset all settings to their default values
    func resetToDefaults()
    {
        selectedCamera = .back
        showPOIList = false
        showCompass = true
        showHorizon = true
        selectedPOITypes = Set(POIType.allCases)
        maxPOIDistance = 100_000
        maxListDistance = 50_000
        distanceUnit = .metric
        visitedRoutePOIs = []
    }
    
    /// Reset all route POI visits
    func resetRouteVisits()
    {
        visitedRoutePOIs = []
        // Post notification so tracker can reset its internal state
        NotificationCenter.default.post(name: .routeVisitsReset, object: nil)
    }
    
    /// Mark a route POI as visited
    func markRouteVisited(_ poiName: String)
    {
        visitedRoutePOIs.insert(poiName)
    }
    
    /// Check if a route POI has been visited
    func isRouteVisited(_ poiName: String) -> Bool
    {
        visitedRoutePOIs.contains(poiName)
    }
}
// MARK: - Notification Names

extension Notification.Name
{
    static let routeVisitsReset = Notification.Name("routeVisitsReset")
}

