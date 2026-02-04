//
//  RadarView.swift
//  HUDView
//
//  Created by Stuart Rankin on 2/1/26.
//

import SwiftUI
import CoreLocation

struct RadarView: View
{
    let visiblePOIs: [POIVisibilityService.VisiblePOI]
    let currentHeading: Double
    let maxDistance: Double
    let distanceUnit: HUDSettings.DistanceUnit
    @Environment(\.dismiss) var dismiss
    
    private let ringCount = 4
    
    // Zoom state
    @State private var currentZoomScale: Double = 1.0
    @State private var activeZoomScale: Double = 1.0
    @GestureState private var magnifyBy = 1.0
    
    // Device orientation tracking
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    // Computed heading adjustment based on device orientation
    private var orientationOffset: Double {
        switch orientation {
        case .landscapeLeft:
            return 90.0  // Rotate 90° clockwise
        case .landscapeRight:
            return -90.0  // Rotate 90° counter-clockwise
        default:
            return 0.0  // Portrait or unknown
        }
    }
    
    // Adjusted heading that accounts for device orientation
    private var adjustedHeading: Double {
        return currentHeading + orientationOffset
    }
    
    var body: some View
    {
        NavigationStack
        {
            GeometryReader
            {
                geometry in
                radarContent(geometry: geometry)
            }
            .navigationTitle("Radar View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .confirmationAction)
                {
                    Button
                    {
                        dismiss()
                    }
                label:
                    {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear {
            // Start monitoring device orientation
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                orientation = UIDevice.current.orientation
            }
        }
        .onDisappear {
            // Stop monitoring device orientation
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    // Pulse animation state
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0
    
    // Computed property for effective max distance based on zoom
    private var effectiveMaxDistance: Double
    {
        maxDistance / currentZoomScale
    }
    
    // Computed property for POI position scaling (60% of zoom)
    private var poiScaleFactor: Double
    {
        1.0 + (currentZoomScale - 1.0) * 0.6
    }
    
    // Computed property for active POI scaling including gesture
    private var activePoiScaleFactor: Double
    {
        1.0 + ((currentZoomScale * magnifyBy) - 1.0) * 0.6
    }
    
    // Magnification gesture for zoom
    private var magnificationGesture: some Gesture
    {
        MagnificationGesture()
            .updating($magnifyBy) { value, gestureState, _ in
                gestureState = value
            }
            .onEnded { value in
                // Clamp zoom between 0.25x (4x distance) and 8x (1/8 distance)
                let newScale = currentZoomScale * value
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7))
                {
                    currentZoomScale = min(max(newScale, 0.25), 8.0)
                }
            }
    }
    
    private func radarContent(geometry: GeometryProxy) -> some View
    {
        let size = min(geometry.size.width, geometry.size.height) * 0.85
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        
        return ZStack
        {
            Color.black.ignoresSafeArea()
            
            radarDisplay(size: size, center: center)
                .onTapGesture(count: 2)
                {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7))
                    {
                        currentZoomScale = 1.0
                    }
                }
            
            infoOverlay
        }
    }
    
    private func radarDisplay(size: CGFloat, center: CGPoint) -> some View
    {
        ZStack
        {
            backgroundCircle(size: size)
            concentricRings(size: size, center: center)
            cardinalLines(size: size, center: center)
            headingIndicator(size: size, center: center)
            northLabel(size: size, center: center)
            pulsingEffect(size: size)
            userLocationMarker(size: size)
            poiMarkers(size: size, center: center)
        }
        .frame(width: size, height: size)
        .position(center)
        .gesture(magnificationGesture)
    }
    
    private func backgroundCircle(size: CGFloat) -> some View
    {
        Circle()
            .fill(Color.green.opacity(0.1))
            .frame(width: size, height: size)
    }
    
    private func concentricRings(size: CGFloat, center: CGPoint) -> some View
    {
        ForEach(1...ringCount, id: \.self)
        {
            ring in
            ringView(ring: ring, size: size, center: center)
        }
    }
    
    private func ringView(ring: Int, size: CGFloat, center: CGPoint) -> some View
    {
        let ringSize = size * CGFloat(ring) / CGFloat(ringCount)
        let ringDistance = effectiveMaxDistance * Double(ring) / Double(ringCount)
        
        // Use radar's own coordinate space
        let radarCenter = CGPoint(x: size / 2, y: size / 2)
        
        return Circle()
            .stroke(Color.green.opacity(0.3), lineWidth: 1)
            .frame(width: ringSize, height: ringSize)
            .overlay(alignment: .top) {
                Text(distanceUnit.format(meters: ringDistance))
                    .font(.caption2)
                    .foregroundColor(.green.opacity(0.6))
                    .offset(y: -10)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
            }
    }
    
    private func cardinalLines(size: CGFloat, center: CGPoint) -> some View
    {
        let radarCenter = CGPoint(x: size / 2, y: size / 2)
        
        return Path
        {
            path in
            // North-South
            path.move(to: CGPoint(x: radarCenter.x, y: radarCenter.y - size / 2))
            path.addLine(to: CGPoint(x: radarCenter.x, y: radarCenter.y + size / 2))
            
            // East-West
            path.move(to: CGPoint(x: radarCenter.x - size / 2, y: radarCenter.y))
            path.addLine(to: CGPoint(x: radarCenter.x + size / 2, y: radarCenter.y))
        }
        .stroke(Color.green.opacity(0.2), lineWidth: 1)
    }
    
    private func headingIndicator(size: CGFloat, center: CGPoint) -> some View
    {
        let radarCenter = CGPoint(x: size / 2, y: size / 2)
        let angle = -adjustedHeading * .pi / 180
        let length = size / 2
        let endX = radarCenter.x + length * sin(angle)
        let endY = radarCenter.y - length * cos(angle)
        
        return Path
        {
            path in
            path.move(to: radarCenter)
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        .stroke(Color.yellow.opacity(0.8), lineWidth: 2)
    }
    
    private func northLabel(size: CGFloat, center: CGPoint) -> some View
    {
        let radarCenter = CGPoint(x: size / 2, y: size / 2)
        let angle = -adjustedHeading * .pi / 180
        let xPos = radarCenter.x + (size / 2 + 20) * sin(angle)
        let yPos = radarCenter.y - (size / 2 + 20) * cos(angle)
        
        return Text("N")
            .font(.headline)
            .foregroundColor(.yellow)
            .rotationEffect(.degrees(-adjustedHeading))
            .position(x: xPos, y: yPos)
    }
    
    private func poiMarkers(size: CGFloat, center: CGPoint) -> some View
    {
        // Sort POIs by distance (farthest first) so closest are drawn on top
        let sortedPOIs = visiblePOIs.enumerated().sorted { $0.element.distance > $1.element.distance }
        
        return ForEach(sortedPOIs, id: \.offset)
        {
            indexedPOI in
            poiMarkerView(poi: indexedPOI.element, size: size, center: center)
        }
        .zIndex(100)
    }
    
    @ViewBuilder private func poiMarkerView(poi: POIVisibilityService.VisiblePOI, size: CGFloat,
                                            center: CGPoint) -> some View
    {
        if poi.distance <= effectiveMaxDistance
        {
            // Calculate position relative to radar's own coordinate space (center of radar)
            let radarCenter = CGPoint(x: size / 2, y: size / 2)
            let basePosition = calculatePOIPosition(
                poi: poi,
                center: radarCenter,
                radarRadius: size / 2,
                maxDistance: effectiveMaxDistance,
                currentHeading: adjustedHeading
            )
            
            // Apply 60% scaling to the position offset from center
            let offsetX = (basePosition.x - radarCenter.x) * activePoiScaleFactor
            let offsetY = (basePosition.y - radarCenter.y) * activePoiScaleFactor
            let scaledPosition = CGPoint(
                x: radarCenter.x + offsetX,
                y: radarCenter.y + offsetY
            )
            
            RadarPOIMarker(poi: poi, iconScale: activePoiScaleFactor)
                .position(scaledPosition)
        }
    }
    
    private func userLocationMarker(size: CGFloat) -> some View
    {
        Circle()
            .fill(Color.blue)
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .position(x: size / 2, y: size / 2)
    }
    
    private func pulsingEffect(size: CGFloat) -> some View
    {
        Circle()
            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            .frame(width: 20, height: 20)
            .scaleEffect(pulseScale)
            .opacity(1 - pulseOpacity)
            .position(x: size / 2, y: size / 2)
            .onAppear {
                startPulseAnimation()
            }
    }
    
    private var infoOverlay: some View
    {
        VStack
        {
            VStack(alignment: .leading, spacing: 4)
            {
                Text("Heading: \(Int(adjustedHeading))°")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("Range: \(distanceUnit.format(meters: effectiveMaxDistance))")
                    .font(.caption)
                    .foregroundColor(.green)
                if currentZoomScale != 1.0
                {
                    Text("Zoom: \(String(format: "%.1fx", currentZoomScale))")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                let visibleCount = visiblePOIs.filter { $0.distance <= effectiveMaxDistance }.count
                Text("POIs: \(visibleCount) of \(visiblePOIs.count)")
                    .font(.caption)
                    .foregroundColor(.green)
                if visiblePOIs.isEmpty {
                    Text("⚠️ No POIs in range")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(8)
            .fixedSize(horizontal: true, vertical: false)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
    }
    
    private func startPulseAnimation()
    {
        withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false))
        {
            pulseScale = 2.5
            pulseOpacity = 1.0
        }
    }
    
    private func calculatePOIPosition(poi: POIVisibilityService.VisiblePOI, center: CGPoint,
                                      radarRadius: CGFloat, maxDistance: Double,
                                      currentHeading: Double ) -> CGPoint
    {
        // Calculate relative bearing (accounting for device heading)
        let relativeBearing = poi.bearing - currentHeading
        let angleRadians = relativeBearing * .pi / 180
        
        // Calculate distance as percentage of max distance
        let distanceRatio = min(poi.distance / maxDistance, 1.0)
        let radius = radarRadius * CGFloat(distanceRatio)
        
        // Calculate position (0° is north, clockwise)
        let x = center.x + radius * sin(angleRadians)
        let y = center.y - radius * cos(angleRadians)
        
        return CGPoint(x: x, y: y)
    }
}

struct RadarPOIMarker: View
{
    let poi: POIVisibilityService.VisiblePOI
    let iconScale: Double
    @State private var showLabel = false
    @State private var settings = HUDSettings.shared
    
    // Computed sizes with minimum bounds
    private var outerSize: CGFloat { max(32 * iconScale, 16) }
    private var circleSize: CGFloat { max(24 * iconScale, 12) }
    private var iconSize: CGFloat { max(11 * iconScale, 8) }
    
    var body: some View
    {
        VStack(spacing: 2)
        {
            // POI icon with better visibility
            ZStack
            {
                // Outer glow/ring for visibility (only for non-route POIs)
                if poi.poi.type != .route
                {
                    Circle()
                        .fill(poiColor.opacity(0.4))
                        .frame(width: outerSize, height: outerSize)
                }
                
                // Background circle
                Circle()
                    .fill(backgroundColor)
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        Circle()
                            .stroke(outlineColor, lineWidth: outlineWidth)
                    )
                
                // Icon on top - always visible
                Image(systemName: poi.poi.type.icon)
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundColor(iconColor)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0)
                    .drawingGroup() // Force render as bitmap for performance/reliability
            }
            .allowsHitTesting(true)
            .contentShape(Circle())
            .drawingGroup() // Composite the entire marker
            .onTapGesture
            {
                withAnimation
                {
                    showLabel.toggle()
                }
            }
            
            // Label (shown on tap)
            if showLabel
            {
                VStack(spacing: 2)
                {
                    Text(poi.poi.name)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(poi.distanceFormatted)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(4)
                .background(Color.black.opacity(0.9))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(iconColor, lineWidth: 1)
                )
                .transition(.opacity)
            }
        }
    }
    
    private var backgroundColor: Color
    {
        // Route waypoints get dark gray background
        if poi.poi.type == .route
        {
            return Color(white: 0.25) // Dark gray
        }
        // Other POIs use their type color as background
        return poiColor
    }
    
    private var outlineColor: Color
    {
        // Route waypoints get black outline
        if poi.poi.type == .route
        {
            return .black
        }
        // Other POIs have no special outline
        return .clear
    }
    
    private var outlineWidth: CGFloat
    {
        // Route waypoints get thicker outline
        if poi.poi.type == .route
        {
            return 2
        }
        return 0
    }
    
    private var iconColor: Color
    {
        // Route waypoints change icon color based on visited state
        if poi.poi.type == .route
        {
            if settings.isRouteVisited(poi.poi.name)
            {
                return Color(red: 0, green: 1, blue: 0) // Bright green
            }
            else
            {
                return Color(white: 0.7) // Light gray
            }
        }
        // Other POIs get white icons
        return .white
    }
    
    private var poiColor: Color
    {
        // Check if this is a route POI and if it's been visited
        if poi.poi.type == .route
        {
            if settings.isRouteVisited(poi.poi.name)
            {
                return .green // Visited route POIs are green
            }
            else
            {
                return .yellow // Unvisited route POIs are yellow for visibility on dark radar
            }
        }
        
        // For non-route POIs, use the standard color
        switch poi.poi.type.color
        {
        case "orange": return .orange
        case "brown": return .brown
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "black": return .white // Show black as white on dark background
        default: return .white
        }
    }
}

#Preview
{
    let testPOIs = [
        POIVisibilityService.VisiblePOI(
            poi: POI(name: "Test City", latitude: 37.7749, longitude: -122.4194, type: .city),
            distance: 5000,
            bearing: 45,
            bearingDifference: 10
        ),
        POIVisibilityService.VisiblePOI(
            poi: POI(name: "Test Mountain", latitude: 37.8816, longitude: -121.9144, type: .mountain),
            distance: 15000,
            bearing: 180,
            bearingDifference: 5
        )
    ]
    
    RadarView(
        visiblePOIs: testPOIs,
        currentHeading: 0,
        maxDistance: 20000,
        distanceUnit: .metric
    )
}
