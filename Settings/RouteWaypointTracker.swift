//
//  RouteWaypointTracker.swift
//  HUDView
//
//  Created by Stuart Rankin on 2/1/26.
//

import Foundation
import CoreLocation
import Observation

/// Tracks when user visits route waypoints based on proximity and dwell time
@Observable class RouteWaypointTracker
{
    private let settings = HUDSettings.shared
    private let proximityThreshold: Double = 20.0 // meters
    private let dwellTimeRequired: TimeInterval = 1.0 // seconds
    
    /// Track when user entered proximity of each waypoint
    private var proximityEntryTimes: [String: Date] = [:]
    
    init()
    {
        // Listen for route visits reset notification
        NotificationCenter.default.addObserver(
            forName: .routeVisitsReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resetProximityTracking()
        }
    }
    
    /// Check if user is visiting any waypoints and mark them as visited if conditions are met
    func checkWaypointProximity(userLocation: CLLocationCoordinate2D)
    {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let now = Date()
        
        // Check each route waypoint
        for waypoint in NorthernCaliforniaData.routePOIs
        {
            // Skip if already visited
            if settings.isRouteVisited(waypoint.name)
            {
                continue
            }
            
            // Calculate distance to waypoint
            let waypointLocation = CLLocation(
                latitude: waypoint.coordinate.latitude,
                longitude: waypoint.coordinate.longitude
            )
            let distance = userCLLocation.distance(from: waypointLocation)
            
            if distance <= proximityThreshold
            {
                // User is within proximity threshold
                if let entryTime = proximityEntryTimes[waypoint.name]
                {
                    // Check if user has been here long enough
                    let dwellTime = now.timeIntervalSince(entryTime)
                    if dwellTime >= dwellTimeRequired
                    {
                        // Mark as visited!
                        settings.markRouteVisited(waypoint.name)
                        proximityEntryTimes.removeValue(forKey: waypoint.name)
                        
                        print("✅ Waypoint visited: \(waypoint.name) (distance: \(String(format: "%.1f", distance))m, dwell time: \(String(format: "%.1f", dwellTime))s)")
                    }
                }
                else
                {
                    // First time entering proximity - record entry time
                    proximityEntryTimes[waypoint.name] = now
                    print("📍 Entered proximity of \(waypoint.name) (distance: \(String(format: "%.1f", distance))m)")
                }
            }
            else
            {
                // User left proximity - reset entry time
                if proximityEntryTimes[waypoint.name] != nil
                {
                    proximityEntryTimes.removeValue(forKey: waypoint.name)
                    print("🚶 Left proximity of \(waypoint.name)")
                }
            }
        }
    }
    
    /// Reset all proximity tracking (useful when resetting route visits)
    func resetProximityTracking()
    {
        proximityEntryTimes.removeAll()
    }
}
