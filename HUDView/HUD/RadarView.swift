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
    }
    
    // Pulse animation state
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0
    
    private func radarContent(geometry: GeometryProxy) -> some View
    {
        let size = min(geometry.size.width, geometry.size.height) * 0.85
        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        
        return ZStack
        {
            Color.black.ignoresSafeArea()
            
            radarDisplay(size: size, center: center)
            
            infoOverlay
            
            // Debug info at bottom
            VStack
            {
                Spacer()
                if visiblePOIs.isEmpty
                {
                    Text("No POIs found in \(distanceUnit.format(meters: maxDistance)) radius")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                }
            }
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
            poiMarkers(size: size, center: center)
            userLocationMarker(size: size)
            pulsingEffect(size: size)
        }
        .frame(width: size, height: size)
        .position(center)
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
        let ringDistance = maxDistance * Double(ring) / Double(ringCount)
        
        // Use radar's own coordinate space
        let radarCenter = CGPoint(x: size / 2, y: size / 2)
        
        return ZStack
        {
            Circle()
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                .frame(width: ringSize, height: ringSize)
            
            Text(distanceUnit.format(meters: ringDistance))
                .font(.caption2)
                .foregroundColor(.green.opacity(0.6))
                .position(x: radarCenter.x, y: radarCenter.y - ringSize / 2 - 10)
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
        let angle = -currentHeading * .pi / 180
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
        let angle = -currentHeading * .pi / 180
        let xPos = radarCenter.x + (size / 2 + 20) * sin(angle)
        let yPos = radarCenter.y - (size / 2 + 20) * cos(angle)
        
        return Text("N")
            .font(.headline)
            .foregroundColor(.yellow)
            .rotationEffect(.degrees(-currentHeading))
            .position(x: xPos, y: yPos)
    }
    
    private func poiMarkers(size: CGFloat, center: CGPoint) -> some View
    {
        ForEach(visiblePOIs.indices, id: \.self)
        {
            index in
            poiMarkerView(poi: visiblePOIs[index], size: size, center: center)
        }
    }
    
    @ViewBuilder private func poiMarkerView(poi: POIVisibilityService.VisiblePOI, size: CGFloat,
                                            center: CGPoint) -> some View
    {
        if poi.distance <= maxDistance
        {
            // Calculate position relative to radar's own coordinate space (center of radar)
            let radarCenter = CGPoint(x: size / 2, y: size / 2)
            let position = calculatePOIPosition(
                poi: poi,
                center: radarCenter,
                radarRadius: size / 2,
                maxDistance: maxDistance,
                currentHeading: currentHeading
            )
            
            RadarPOIMarker(poi: poi)
                .position(position)
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
            HStack
            {
                VStack(alignment: .leading, spacing: 4)
                {
                    Text("Heading: \(Int(currentHeading))°")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("Range: \(distanceUnit.format(meters: maxDistance))")
                        .font(.caption)
                        .foregroundColor(.green)
                    let visibleCount = visiblePOIs.filter { $0.distance <= maxDistance }.count
                    Text("POIs: \(visibleCount) of \(visiblePOIs.count)")
                        .font(.caption)
                        .foregroundColor(.green)
                    if visiblePOIs.isEmpty {
                        Text("⚠️ No POIs in range")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(8)
            .padding()
            
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
    @State private var showLabel = false
    
    var body: some View
    {
        VStack(spacing: 2)
        {
            // POI icon with better visibility
            ZStack
            {
                // Outer glow/ring for visibility
                Circle()
                    .fill(poiColor.opacity(0.3))
                    .frame(width: 28, height: 28)
                
                // Inner circle background
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 22, height: 22)
                
                // Icon
                Image(systemName: poi.poi.type.icon)
                    .font(.system(size: 12))
                    .foregroundColor(poiColor)
            }
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
                        .stroke(poiColor, lineWidth: 1)
                )
                .transition(.opacity)
            }
        }
    }
    
    private var poiColor: Color
    {
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
