//
//  POIData.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import Foundation
import CoreLocation

/// Represents a point of interest (landmark or city)
struct POI: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: POIType
    let description: String?
    let elevation: Double? // meters
    let population: Int? // for cities
    
    init(name: String, latitude: Double, longitude: Double, type: POIType,
         description: String? = nil, elevation: Double? = nil, population: Int? = nil) {
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.type = type
        self.description = description
        self.elevation = elevation
        self.population = population
    }
}

/// Type of point of interest
enum POIType: String, CaseIterable {
    case city
    case mountain
    case bridge
    case park
    case lake
    case bay
    case island
    case beach
    case forest
    case volcano
    case valley
    case river
    case canyon
    case test
    
    var icon: String {
        switch self {
        case .city: return "building.2.fill"
        case .mountain: return "mountain.2.fill"
        case .bridge: return "point.topright.down.curvedto.point.bottomleft.up.fill"
        case .park: return "tree.fill"
        case .lake: return "drop.fill"
        case .bay: return "water.waves"
        case .island: return "location.fill"
        case .beach: return "beach.umbrella.fill"
        case .forest: return "tree.fill"
        case .volcano: return "mountain.2.fill"
        case .valley: return "mountain.2.fill"
        case .river: return "water.waves"
        case .canyon: return "mountain.2.fill"
        case .test: return "testtube.2"
        }
    }
    
    var color: String {
        switch self {
        case .city: return "orange"
        case .mountain: return "brown"
        case .bridge: return "red"
        case .park: return "green"
        case .lake, .bay, .river: return "blue"
        case .island: return "mint"
        case .beach: return "cyan"
        case .forest: return "green"
        case .volcano: return "red"
        case .valley: return "brown"
        case .canyon: return "orange"
        case .test: return "purple"
        }
    }
    
    var displayName: String {
        switch self {
        case .city: return "Cities"
        case .mountain: return "Mountains"
        case .bridge: return "Bridges"
        case .park: return "Parks"
        case .lake: return "Lakes"
        case .bay: return "Bays"
        case .island: return "Islands"
        case .beach: return "Beaches"
        case .forest: return "Forests"
        case .volcano: return "Volcanoes"
        case .valley: return "Valleys"
        case .river: return "Rivers"
        case .canyon: return "Canyons"
        case .test: return "Test"
        }
    }
}

/// Database of Northern California landmarks and cities
struct NorthernCaliforniaData {
    
    // MARK: - Major Cities (Population > 50,000)
    
    static let cities: [POI] = [
        // Bay Area
        POI(name: "San Francisco", latitude: 37.7749, longitude: -122.4194, type: .city, population: 873_965),
        POI(name: "San Jose", latitude: 37.3382, longitude: -121.8863, type: .city, population: 1_013_240),
        POI(name: "Oakland", latitude: 37.8044, longitude: -122.2712, type: .city, population: 440_646),
        POI(name: "Fremont", latitude: 37.5485, longitude: -121.9886, type: .city, population: 230_504),
        POI(name: "Santa Clara", latitude: 37.3541, longitude: -121.9552, type: .city, population: 127_647),
        POI(name: "Sunnyvale", latitude: 37.3688, longitude: -122.0363, type: .city, population: 155_805),
        POI(name: "Hayward", latitude: 37.6688, longitude: -122.0808, type: .city, population: 162_954),
        POI(name: "Berkeley", latitude: 37.8715, longitude: -122.2730, type: .city, population: 124_321),
        POI(name: "Mountain View", latitude: 37.3861, longitude: -122.0839, type: .city, population: 82_739),
        POI(name: "Palo Alto", latitude: 37.4419, longitude: -122.1430, type: .city, population: 68_572),
        POI(name: "Santa Rosa", latitude: 38.4404, longitude: -122.7141, type: .city, population: 178_127),
        POI(name: "Richmond", latitude: 37.9358, longitude: -122.3477, type: .city, population: 116_448),
        POI(name: "Concord", latitude: 37.9780, longitude: -122.0311, type: .city, population: 129_295),
        POI(name: "Vallejo", latitude: 38.1041, longitude: -122.2566, type: .city, population: 126_090),
        POI(name: "Redwood City", latitude: 37.521037, longitude: -122.256810, type: .city, population: 0),

        // HQ
        POI(name: "Washington DC", latitude: 38.9073, longitude: 77.0369, type: .city, population: 702_250),
        
        // Japan
        POI(name: "Sapporo", latitude: 43.0618, longitude: 141.3545, type: .city, population: 1_967_361),
        POI(name: "Yubari", latitude: 43.0568, longitude: 141.9739, type: .city, population: 6_374),
        POI(name: "Tokyo", latitude: 35.6764, longitude: 139.6500, type: .city, population: 14_000_000),
        
        // Foothills
        POI(name: "Placerville", latitude: 38.7296, longitude: -120.7985, type: .city, population: 10_747),
        POI(name: "Jackson", latitude: 38.3488, longitude: -120.7741, type: .city, population: 5_079),
        
        // Sacramento Region
        POI(name: "Sacramento", latitude: 38.5816, longitude: -121.4944, type: .city, population: 524_943),
        POI(name: "Elk Grove", latitude: 38.4088, longitude: -121.3716, type: .city, population: 176_124),
        POI(name: "Roseville", latitude: 38.7521, longitude: -121.2880, type: .city, population: 147_773),
        
        // Central Valley
        POI(name: "Stockton", latitude: 37.9577, longitude: -121.2908, type: .city, population: 320_554),
        POI(name: "Modesto", latitude: 37.6391, longitude: -120.9969, type: .city, population: 218_464),
    ]
    
    // MARK: - Major Landmarks
    
    static let landmarks: [POI] = [
        // Mountains & Peaks
        POI(name: "Mount Shasta", latitude: 41.4092, longitude: -122.1949, type: .volcano, elevation: 4322),
        POI(name: "Mount Diablo", latitude: 37.8816, longitude: -121.9144, type: .mountain, elevation: 1173),
        POI(name: "Mount Tamalpais", latitude: 37.9235, longitude: -122.5965, type: .mountain, elevation: 784),
        POI(name: "Mount Hamilton", latitude: 37.3414, longitude: -121.6426, type: .mountain, elevation: 1283),
        POI(name: "Mount Whitney", latitude: 36.5785, longitude: -118.2923, type: .mountain, elevation: 4421),
        POI(name: "Pyramid Peak", latitude: 38.8450, longitude: -120.1578, type: .mountain, elevation: 3043),
        POI(name: "富士山", latitude: 35.35806, longitude: 138.73, type: .mountain, elevation: 3776),
        
        // Bridges
        POI(name: "Golden Gate Bridge", latitude: 37.8199, longitude: -122.4783, type: .bridge),
        POI(name: "Bay Bridge", latitude: 37.8098, longitude: -122.3647, type: .bridge),
        
        // Parks
        POI(name: "Yosemite NP", latitude: 37.8651, longitude: -119.5383, type: .park),
        POI(name: "Point Reyes", latitude: 38.0467, longitude: -122.8794, type: .park),
        POI(name: "Muir Woods", latitude: 37.8916, longitude: -122.5808, type: .forest),
        
        // Water Features
        POI(name: "Lake Tahoe", latitude: 39.0968, longitude: -120.0324, type: .lake, elevation: 1897),
        POI(name: "San Francisco Bay", latitude: 37.7850, longitude: -122.3100, type: .bay),
        POI(name: "Monterey Bay", latitude: 36.8028, longitude: -121.9000, type: .bay),
        
        // Islands
        POI(name: "Alcatraz Island", latitude: 37.8267, longitude: -122.4230, type: .island),
        POI(name: "Angel Island", latitude: 37.8604, longitude: -122.4327, type: .island),
    ]
    
    // MARK: - Test POIs
    
    static let testPOIs: [POI] = [
        POI(name: "Home", latitude: 38.00665, longitude: 121.35991, type: .test, description: "Home"),
        POI(name: "Work", latitude: 37.521037, longitude: -122.256810, type: .test, description: "RWC Office"),
        POI(name: "Old House", latitude: 38.631662, longitude: -120.930632, type: .test, description: "Shingle Springs"),
        POI(name: "Test Point North", latitude: 0.0, longitude: 0.0, type: .test, description: "Test marker 1"),
        POI(name: "Test Point South", latitude: 0.0, longitude: -90.0, type: .test, description: "Test marker 2"),
        POI(name: "Test Point East", latitude: 90.0, longitude: -0.0, type: .test, description: "Test marker 3"),
        POI(name: "Test Point West", latitude: -90.0, longitude: -0.0, type: .test, description: "Test marker 4"),
    ]
    
    // MARK: - Combined Data
    
    static var allPOIs: [POI] {
        cities + landmarks + testPOIs
    }
}

// MARK: - POI Visibility Service

/// Calculates which POIs are visible based on camera direction and location
struct POIVisibilityService {
    
    /// Represents a POI with additional visibility information
    struct VisiblePOI {
        let poi: POI
        let distance: Double // meters
        let bearing: Double // degrees (0-360, where 0 is north)
        let bearingDifference: Double // degrees from camera heading
        
        var distanceFormatted: String {
            HUDSettings.shared.distanceUnit.format(meters: distance)
        }
    }
    
    /// Find POIs visible in the camera's field of view
    static func visiblePOIs(
        from userLocation: CLLocationCoordinate2D,
        heading: Double,
        fieldOfView: Double = 60,
        maxDistance: Double = 100_000,
        limit: Int = 10,
        typeFilter: Set<POIType>? = nil
    ) -> [VisiblePOI] {
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        // Filter by type if specified
        let filteredPOIs = if let typeFilter = typeFilter, !typeFilter.isEmpty {
            NorthernCaliforniaData.allPOIs.filter { typeFilter.contains($0.type) }
        } else {
            NorthernCaliforniaData.allPOIs
        }
        
        let poisWithBearing: [VisiblePOI] = filteredPOIs.compactMap { poi in
            let poiLocation = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
            let distance = userCLLocation.distance(from: poiLocation)
            
            guard distance <= maxDistance else { return nil }
            
            let bearing = calculateBearing(from: userLocation, to: poi.coordinate)
            let bearingDiff = normalizeAngleDifference(heading, bearing)
            
            let halfFOV = fieldOfView / 2
            guard abs(bearingDiff) <= halfFOV else { return nil }
            
            return VisiblePOI(
                poi: poi,
                distance: distance,
                bearing: bearing,
                bearingDifference: bearingDiff
            )
        }
        
        return poisWithBearing
            .sorted { $0.distance < $1.distance }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get nearest POIs regardless of camera direction
    static func nearestPOIs(
        from userLocation: CLLocationCoordinate2D,
        maxDistance: Double = 50_000,
        limit: Int = 5,
        typeFilter: Set<POIType>? = nil
    ) -> [VisiblePOI] {
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        // Filter by type if specified
        let filteredPOIs = if let typeFilter = typeFilter, !typeFilter.isEmpty {
            NorthernCaliforniaData.allPOIs.filter { typeFilter.contains($0.type) }
        } else {
            NorthernCaliforniaData.allPOIs
        }
        
        let poisWithDistance: [VisiblePOI] = filteredPOIs.compactMap { poi in
            let poiLocation = CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude)
            let distance = userCLLocation.distance(from: poiLocation)
            
            guard distance <= maxDistance else { return nil }
            
            let bearing = calculateBearing(from: userLocation, to: poi.coordinate)
            
            return VisiblePOI(
                poi: poi,
                distance: distance,
                bearing: bearing,
                bearingDifference: 0
            )
        }
        
        return poisWithDistance
            .sorted { $0.distance < $1.distance }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Helper Methods
    
    private static func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude.degreesToRadians
        let lon1 = from.longitude.degreesToRadians
        let lat2 = to.latitude.degreesToRadians
        let lon2 = to.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        let bearing = atan2(y, x).radiansToDegrees
        
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    private static func normalizeAngleDifference(_ angle1: Double, _ angle2: Double) -> Double {
        var diff = angle2 - angle1
        
        while diff > 180 {
            diff -= 360
        }
        while diff < -180 {
            diff += 360
        }
        
        return diff
    }
}

// MARK: - Extensions

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
