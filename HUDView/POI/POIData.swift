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
    case forest
    case volcano
    case river
    case test
    case route
    
    var icon: String {
        switch self {
        case .city: return "building.2.fill"
        case .mountain: return "triangle.fill"
        case .bridge: return "water.waves.and.arrow.trianglehead.up"
        case .park: return "tree.fill"
        case .lake: return "drop.fill"
        case .forest: return "tree.fill"
        case .volcano: return "triangle.fill"
        case .river: return "water.waves"
        case .test: return "testtube.2"
        case .route: return "mappin.and.ellipse"
        }
    }
    
    var color: String {
        switch self {
        case .city: return "orange"
        case .mountain: return "brown"
        case .bridge: return "red"
        case .park: return "green"
        case .lake, .river: return "blue"
        case .forest: return "green"
        case .volcano: return "red"
        case .test: return "purple"
            case .route: return "black"
        }
    }
    
    var displayName: String {
        switch self {
        case .city: return "Cities"
        case .mountain: return "Mountains"
        case .bridge: return "Bridges"
        case .park: return "Parks"
        case .lake: return "Lakes"
        case .forest: return "Forests"
        case .volcano: return "Volcanoes"
        case .river: return "Rivers"
        case .test: return "Test"
            case .route: return "Route Waypoint"
        }
    }
}

/// Database of Northern California landmarks and cities
struct NorthernCaliforniaData {
    
    // MARK: - Major Cities
    
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
        POI(name: "Redwood City", latitude: 37.521037, longitude: -122.256810, type: .city, population: 84_292),
        POI(name: "Danville", latitude: 37.8216, longitude: -121.9999, type: .city, population: 43_100),
        
        // HQ
        POI(name: "Washington DC", latitude: 38.9073, longitude: -77.0369, type: .city, population: 702_250),
        
        // Japan
        POI(name: "札幌", latitude: 43.0618, longitude: 141.3545, type: .city, population: 1_967_361),
        POI(name: "夕張", latitude: 43.0568, longitude: 141.9739, type: .city, population: 6_374),
        POI(name: "東京", latitude: 35.6764, longitude: 139.6500, type: .city, population: 14_000_000),
        
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
        POI(name: "Fresno", latitude: 36.7442, longitude: -119.7631, type: .city, population: 550_000)
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
        POI(name: "San Mateo Bridge", latitude: 37.5907, longitude: -122.2429, type: .bridge),
        POI(name: "Dumbarton Bridge", latitude: 37.5048, longitude: -122.1204, type: .bridge),
        
        // Parks
        POI(name: "Yosemite", latitude: 37.8651, longitude: -119.5383, type: .park),
        POI(name: "Point Reyes", latitude: 38.0467, longitude: -122.8794, type: .park),
        POI(name: "Muir Woods", latitude: 37.8916, longitude: -122.5808, type: .forest),
        
        // Water Features
        POI(name: "Lake Tahoe", latitude: 39.0968, longitude: -120.0324, type: .lake, elevation: 1897),
    ]
    
    // MARK: - Test POIs
    
    static let testPOIs: [POI] = [
        POI(name: "Home", latitude: 38.00665, longitude: 121.35991, type: .test, description: "Home"),
        POI(name: "Work", latitude: 37.521037, longitude: -122.256810, type: .test, description: "RWC Office"),
        POI(name: "Old House", latitude: 38.631662, longitude: -120.930632, type: .test, description: "Shingle Springs"),
    ]
    
    // MARK: - Route Waypoints
    static let routePOIs: [POI] = [
        POI(name: "Waypoint 1", latitude: 38.005653, longitude: -121.360298, type: .route),
        POI(name: "Waypoint 2", latitude: 38.000609, longitude: -121.349935, type: .route),
        POI(name: "Waypoint 3", latitude: 37.932380, longitude: -121.296659, type: .route),
        POI(name: "Waypoint 4", latitude: 37.882020, longitude: -121.279022, type: .route),
        POI(name: "Waypoint 5", latitude: 37.793492, longitude: -121.300949, type: .route),
        POI(name: "Waypoint 6", latitude: 37.766958, longitude: -121.335665, type: .route),
        POI(name: "Waypoint 7", latitude: 37.740780, longitude: -121.503701, type: .route),
        POI(name: "Waypoint 8", latitude: 37.741743, longitude: -121.576895, type: .route),
        POI(name: "Waypoint 9", latitude: 37.719399, longitude: -121.660617, type: .route),
        POI(name: "Waypoint 10", latitude: 37.716279, longitude: -121.706935, type: .route),
        POI(name: "Waypoint 11", latitude: 37.698467, longitude: -121.935376, type: .route),
        POI(name: "Waypoint 12", latitude: 37.693642, longitude: -122.050785, type: .route),
        POI(name: "Waypoint 13", latitude: 37.690452, longitude: -122.091166, type: .route),
        POI(name: "Waypoint 14", latitude: 37.690492, longitude: -122.124317, type: .route),
        POI(name: "Waypoint 15", latitude: 37.684441, longitude: -122.129159, type: .route),
        POI(name: "Waypoint 16", latitude: 37.662685, longitude: -122.105619, type: .route),
        POI(name: "Waypoint 17", latitude: 37.642953, longitude: -122.095042, type: .route),
        POI(name: "Waypoint 18", latitude: 37.619624, longitude: -122.146809, type: .route),
        POI(name: "Waypoint 19", latitude: 37.615711, longitude: -122.159631, type: .route),
        POI(name: "Waypoint 20", latitude: 37.593468, longitude: -122.234334, type: .route),
        POI(name: "Waypoint 21", latitude: 37.571266, longitude: -122.265079, type: .route),
        POI(name: "Waypoint 22", latitude: 37.553470, longitude: -122.295481, type: .route),
        POI(name: "Waypoint 23", latitude: 37.549730, longitude: -122.292932, type: .route),
        POI(name: "Waypoint 24", latitude: 37.527708, longitude: -122.272225, type: .route),
        POI(name: "Waypoint 25", latitude: 37.528499, longitude: -122.263890, type: .route),
        POI(name: "Waypoint 26", latitude: 37.521119, longitude: -122.258117, type: .route),
    ]
    
    // MARK: - Combined Data
    
    static var allPOIs: [POI] {
        cities + landmarks + testPOIs + routePOIs
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
