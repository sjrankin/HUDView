//
//  POIViews.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI

/// Displays POIs overlaid on the camera view as directional points
struct POIOverlayView: View
{
    let visiblePOIs: [POIVisibilityService.VisiblePOI]
    let userElevation: Double? // User's current elevation in meters
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            ZStack
            {
                ForEach(visiblePOIs, id: \.poi.id) { visiblePOI in
                    POIMarker(visiblePOI: visiblePOI)
                        .position(x: calculateHorizontalPosition(
                            bearingDiff: visiblePOI.bearingDifference,
                            width: geometry.size.width),
                                  y: calculateVerticalPosition(
                                    poi: visiblePOI.poi,
                                    distance: visiblePOI.distance,
                                    userElevation: userElevation,
                                    height: geometry.size.height))
                }
            }
        }
    }
    
    /// Calculate horizontal position based on bearing difference from camera heading
    /// - Parameters:
    ///   - bearingDiff: Difference in degrees between camera heading and POI bearing (-30 to +30)
    ///   - width: Screen width
    /// - Returns: X position on screen
    private func calculateHorizontalPosition(bearingDiff: Double, width: CGFloat) -> CGFloat
    {
        // Assuming a 60° field of view (±30° from center)
        // Map -30° to 0, 0° to width/2, +30° to width
        let fieldOfView: Double = 60.0
        let halfFOV = fieldOfView / 2.0
        
        // Clamp to field of view
        let clampedDiff = max(-halfFOV, min(halfFOV, bearingDiff))
        
        // Normalize to 0...1 range (0 = left edge, 0.5 = center, 1 = right edge)
        let normalized = (clampedDiff + halfFOV) / fieldOfView
        
        return CGFloat(normalized) * width
    }
    
    /// Calculate vertical position accounting for elevation and Earth's curvature
    /// - Parameters:
    ///   - poi: The POI being positioned
    ///   - distance: Distance to POI in meters
    ///   - userElevation: User's current elevation in meters
    ///   - height: Screen height
    /// - Returns: Y position on screen
    private func calculateVerticalPosition(poi: POI, distance: Double, userElevation: Double?, height: CGFloat) -> CGFloat
    {
        let screenCenter = height * 0.5
        
        // Calculate elevation angle to POI
        let elevationAngle = calculateElevationAngle(
            poiElevation: poi.elevation,
            userElevation: userElevation,
            distance: distance
        )
        
        // Camera vertical field of view (typical for iPhone)
        let verticalFOV: Double = 40.0 // degrees
        let halfVerticalFOV = verticalFOV / 2.0 // ±20°
        
        // Map angle to screen position
        // Screen Y: 0 = top, height = bottom
        // Positive angle (up) = smaller Y (higher on screen) → subtract offset
        // Negative angle (down) = larger Y (lower on screen) → subtract negative = add
        let angleRatio = elevationAngle / halfVerticalFOV
        let offset = CGFloat(angleRatio) * (height * 0.5) // Use full half-screen
        
        return screenCenter - offset
    }
    
    /// Calculate the elevation angle from user to POI accounting for Earth's curvature
    /// - Parameters:
    ///   - poiElevation: POI's elevation above sea level in meters
    ///   - userElevation: User's elevation above sea level in meters
    ///   - distance: Horizontal distance to POI in meters
    /// - Returns: Elevation angle in degrees (positive = up, negative = down)
    private func calculateElevationAngle(poiElevation: Double?, userElevation: Double?, distance: Double) -> Double
    {
        let earthRadius: Double = 6_371_000 // Earth's radius in meters
        
        // Default elevations if not provided
        let userElev = userElevation ?? 0
        let poiElev = poiElevation ?? 0
        
        // Calculate Earth's curvature drop at this distance
        // Using the formula: drop = distance² / (2 × earthRadius)
        let curvatureDrop = (distance * distance) / (2.0 * earthRadius)
        
        // Effective elevation difference accounting for curvature
        // The POI appears "lower" due to Earth curving away, so we subtract the curvature drop
        // However, the POI's actual elevation above sea level compensates for some of this
        let effectiveElevationDiff = (poiElev - userElev) - curvatureDrop
        
        // Calculate angle using arctangent
        // angle = atan(elevation_difference / horizontal_distance)
        let angleRadians = atan2(effectiveElevationDiff, distance)
        let angleDegrees = angleRadians * 180.0 / .pi
        
        return angleDegrees
    }
}

/// Individual POI marker displayed as a point with label
struct POIMarker: View
{
    let visiblePOI: POIVisibilityService.VisiblePOI
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            // Directional line pointing down to the point
            Rectangle()
                .fill(colorForType.gradient)
                .frame(width: 2, height: 30)
                .shadow(color: .black.opacity(0.5), radius: 2)
            
            // Point marker
            Circle()
                .fill(colorForType)
                .frame(width: 12, height: 12)
                .overlay(Circle()
                        .stroke(.white, lineWidth: 2))
                .shadow(color: .black.opacity(0.5), radius: 3)
            
            // Label with icon and info
            VStack(spacing: 4)
            {
                // Icon
                Image(systemName: visiblePOI.poi.type.icon)
                    .font(.caption)
                    .foregroundStyle(colorForType)
                
                // Name
                Text(visiblePOI.poi.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .fixedSize()
                
                // Distance
                Text(visiblePOI.distanceFormatted)
                    .font(.caption2)
                    .foregroundStyle(.black.opacity(0.8))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2))
            .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(colorForType.opacity(0.5), lineWidth: 1))
            .padding(.top, 4)
        }
        .opacity(opacityForDistance)
    }
    
    private var colorForType: Color
    {
        switch visiblePOI.poi.type.color
        {
            case "orange": return .orange
            case "brown": return .brown
            case "red": return .red
            case "green": return .green
            case "blue": return .blue
            case "mint": return .mint
            case "cyan": return .cyan
            default: return .white
        }
    }
    
    private var opacityForDistance: Double
    {
        let distance = visiblePOI.distance
        if distance < 5000
        {
            return 1.0
        }
        else if distance < 20000
        {
            return 0.9
        }
        else if distance < 50000
        {
            return 0.8
        }
        else
        {
            return 0.7
        }
    }
    
    private func formatPopulation(_ population: Int) -> String
    {
        if population >= 1_000_000
        {
            return String(format: "%.1fM", Double(population) / 1_000_000)
        }
        else if population >= 1_000
        {
            return String(format: "%.0fK", Double(population) / 1_000)
        }
        return "\(population)"
    }
    
    private func formatElevation(_ elevation: Double) -> String
    {
        if elevation >= 1000
        {
            return String(format: "%.1f km", elevation / 1000)
        }
        else
        {
            return String(format: "%.0f m", elevation)
        }
    }
}

/// List view of nearby POIs
struct POIListView: View
{
    let pois: [POIVisibilityService.VisiblePOI]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8)
        {
            Text("Nearby Landmarks")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false)
            {
                HStack(spacing: 12)
                {
                    ForEach(pois, id: \.poi.id) { visiblePOI in
                        POICard(visiblePOI: visiblePOI)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.3), radius: 10)
    }
}

/// Compact card for POI
struct POICard: View
{
    let visiblePOI: POIVisibilityService.VisiblePOI
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            HStack {
                Image(systemName: visiblePOI.poi.type.icon)
                    .foregroundStyle(colorForType)
                
                Text(visiblePOI.poi.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            
            HStack(spacing: 4)
            {
                Image(systemName: "location.fill")
                    .font(.caption2)
                Text(visiblePOI.distanceFormatted)
                    .font(.caption)
            }
            .foregroundStyle(.white.opacity(0.8))
            
            if let population = visiblePOI.poi.population
            {
                HStack(spacing: 4)
                {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                    Text(formatPopulation(population))
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.7))
            }
            
            if let description = visiblePOI.poi.description
            {
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.2), lineWidth: 1))
    }
    
    private var colorForType: Color
    {
        switch visiblePOI.poi.type.color
        {
            case "orange": return .orange
            case "brown": return .brown
            case "red": return .red
            case "green": return .green
            case "blue": return .blue
            case "mint": return .mint
            case "cyan": return .cyan
            default: return .white
        }
    }
    
    private func formatPopulation(_ population: Int) -> String
    {
        if population >= 1_000_000
        {
            return String(format: "%.1fM people", Double(population) / 1_000_000)
        }
        else if population >= 1_000
        {
            return String(format: "%.0fK people", Double(population) / 1_000)
        }
        return "\(population) people"
    }
}
/// Compass bearing indicator showing cardinal directions
struct CompassBearingView: View
{
    let currentHeading: Double
    
    var body: some View
    {
        GeometryReader {
            geometry in
            ZStack
            {
                // Background bar
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 50)
                
                // Direction markers
                HStack(spacing: 0) {
                    ForEach(compassMarkers, id: \.bearing)
                    {
                        marker in
                        CompassMarker(
                            marker: marker,
                            currentHeading: currentHeading,
                            screenWidth: geometry.size.width
                        )
                    }
                }
                
                // Center indicator (crosshair) with heading display
                VStack(spacing: 2)
                {
                    // Numeric heading display with direction
                    VStack(spacing: 0)
                    {
                        Text(formattedHeading)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(cardinalDirection)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule()
                            .fill(.red.opacity(0.9))
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1))
                    
                    // Red crosshair
                    Rectangle()
                        .fill(.red)
                        .frame(width: 2, height: 10)
                    
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 50)
    }
    
    private var formattedHeading: String
    {
        let heading = Int(currentHeading.rounded())
        return "\(heading)°"
    }
    
    private var cardinalDirection: String
    {
        let heading = currentHeading
        
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
            return "N"
        }
    }
    
    private var compassMarkers: [CompassMarkerData]
    {
        [
            CompassMarkerData(bearing: 0, label: "N", isCardinal: true),
            CompassMarkerData(bearing: 45, label: "NE", isCardinal: false),
            CompassMarkerData(bearing: 90, label: "E", isCardinal: true),
            CompassMarkerData(bearing: 135, label: "SE", isCardinal: false),
            CompassMarkerData(bearing: 180, label: "S", isCardinal: true),
            CompassMarkerData(bearing: 225, label: "SW", isCardinal: false),
            CompassMarkerData(bearing: 270, label: "W", isCardinal: true),
            CompassMarkerData(bearing: 315, label: "NW", isCardinal: false),
        ]
    }
}

struct CompassMarkerData
{
    let bearing: Double
    let label: String
    let isCardinal: Bool
}

struct CompassMarker: View
{
    let marker: CompassMarkerData
    let currentHeading: Double
    let screenWidth: CGFloat
    
    var body: some View
    {
        let offset = calculateOffset()
        
        if abs(offset) < screenWidth / 2 + 100
        {
            // Only show if near screen
            VStack(spacing: 4)
            {
                Rectangle()
                    .fill(.white)
                    .frame(width: 2, height: marker.isCardinal ? 15 : 10)
                
                Text(marker.label)
                    .font(marker.isCardinal ? .caption : .caption2)
                    .fontWeight(marker.isCardinal ? .bold : .regular)
                    .foregroundStyle(.white)
            }
            .offset(x: offset)
            .opacity(opacityForDistance(offset))
        }
    }
    
    private func calculateOffset() -> CGFloat
    {
        // Calculate angular difference between marker and current heading
        var diff = marker.bearing - currentHeading
        
        // Normalize to [-180, 180]
        while diff > 180
        {
            diff -= 360
        }
        while diff < -180
        {
            diff += 360
        }
        
        // Map to screen position
        // 60° FOV = screen width
        let degreesPerPixel = 60.0 / Double(screenWidth)
        return CGFloat(diff / degreesPerPixel)
    }
    
    private func opacityForDistance(_ offset: CGFloat) -> Double
    {
        let distance = abs(offset)
        let halfScreen = screenWidth / 2
        
        if distance < halfScreen * 0.7
        {
            return 1.0
        }
        else if distance < halfScreen
        {
            return 0.7
        }
        else
        {
            return 0.3
        }
    }
}

#Preview("Compass Bearing View")
{
    ZStack
    {
        Color.black.ignoresSafeArea()
        
        VStack
        {
            CompassBearingView(currentHeading: 135)
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("Heading: 135° SE")
                    .foregroundStyle(.white)
                    .font(.title2)
                
                Text("The red indicator shows your current heading")
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

