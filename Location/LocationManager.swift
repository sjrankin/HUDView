//
//  LocationManager.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import CoreLocation
import SwiftUI

/// Manages location services and compass heading
@MainActor @Observable class LocationManager: NSObject
{
    private let locationManager = CLLocationManager()
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isAuthorized: Bool
    {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    
    // Computed properties for easy access
    var latitude: Double?
    {
        currentLocation?.coordinate.latitude
    }
    
    var longitude: Double?
    {
        currentLocation?.coordinate.longitude
    }
    
    var altitude: Double?
    {
        currentLocation?.altitude
    }
    
    var trueHeading: Double?
    {
        guard let heading = currentHeading?.trueHeading, heading >= 0 else
        {
            return currentHeading?.magneticHeading
        }
        return heading
    }
    
    var compassDirection: String
    {
        guard let heading = trueHeading else
        {
            return "—"
        }
        
        switch heading
        {
        case 0..<22.5, 337.5...360:
            return "N"
        case 22.5..<67.5:
            return "NE"
        case 67.5..<112.5:
            return "E"
        case 112.5..<157.5:
            return "SE"
        case 157.5..<202.5:
            return "S"
        case 202.5..<247.5:
            return "SW"
        case 247.5..<292.5:
            return "W"
        case 292.5..<337.5:
            return "NW"
        default:
            return "—"
        }
    }
    
    override init()
    {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1 // Update every 1 degree change
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// Request location permission
    func requestPermission()
    {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Start updating location and heading
    func startUpdating()
    {
        guard isAuthorized else { return }
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable()
        {
            locationManager.startUpdatingHeading()
        }
    }
    
    /// Stop updating location and heading
    func stopUpdating()
    {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate
{
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation])
    {
        guard let location = locations.last else
        {
            return
        }
        Task
        {
            @MainActor in
            self.currentLocation = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateHeading newHeading: CLHeading)
    {
        Task
        {
            @MainActor in
            self.currentHeading = newHeading
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        Task
        {
            @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if self.isAuthorized
            {
                self.startUpdating()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location manager error: \(error.localizedDescription)")
    }
}
