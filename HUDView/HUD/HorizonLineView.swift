//
//  HorizonLineView.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI

/// Draws a horizon line representing local elevation
struct HorizonLineView: View
{
    let currentHeading: Double
    let userElevation: Double?
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            Canvas
            {
                context, size in
                drawHorizonLine(context: context, size: size)
            }
        }
    }
    
    private func drawHorizonLine(context: GraphicsContext, size: CGSize)
    {
        let centerY = size.height * 0.5
        
        // Calculate horizon position based on user elevation
        let horizonElevationAngle = calculateHorizonElevation(userElevation: userElevation ?? 0)
        
        // Convert elevation angle to screen Y position
        let verticalFOV: Double = 40 // degrees
        let halfVerticalFOV = verticalFOV / 2
        
        // Clamp angle to visible range
        let clampedAngle = max(-halfVerticalFOV, min(halfVerticalFOV, horizonElevationAngle))
        
        // Map angle to screen position
        // Positive angle (up) = lower Y value (higher on screen)
        let angleRatio = clampedAngle / halfVerticalFOV
        let offset = angleRatio * (size.height * 0.5)
        let y = centerY - offset
        
        // Create straight horizontal line
        let path = Path
        {
            path in
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }
        
        // Draw the horizon line
        context.stroke(
            path,
            with: .color(.white.opacity(0.6)),
            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
        )
        
        // Add glow effect
        context.stroke(
            path,
            with: .color(.blue.opacity(0.3)),
            style: StrokeStyle(lineWidth: 4, dash: [8, 4])
        )
    }
    
    /// Calculate the horizon elevation angle based on user elevation
    private func calculateHorizonElevation(userElevation: Double) -> Double
    {
        // Calculate true geometric horizon based on Earth's curvature
        let earthRadius: Double = 6_371_000 // meters
        
        // Distance to horizon based on height
        // d = sqrt(2 * R * h + h^2)
        // For small h compared to R: d ≈ sqrt(2 * R * h)
        let distanceToHorizon = sqrt(2.0 * earthRadius * userElevation + userElevation * userElevation)
        
        // Angle below horizontal to the horizon
        // θ = arccos(R / (R + h))
        let angleRadians = acos(earthRadius / (earthRadius + userElevation))
        let angleDegrees = -angleRadians * 180.0 / .pi // Negative because it's below horizontal
        
        return angleDegrees
    }
}

/// Horizon line with label
struct HorizonLineWithLabel: View
{
    let currentHeading: Double
    let userElevation: Double?
    @Binding var showHorizon: Bool
    
    var body: some View
    {
        Group
        {
            if showHorizon
            {
                HorizonLineView(
                    currentHeading: currentHeading,
                    userElevation: userElevation
                )
            }
        }
    }
}

#Preview
{
    @Previewable @State var showHorizon = true
    ZStack {
        Color.black.ignoresSafeArea()
        
        HorizonLineWithLabel(
            currentHeading: 45,
            userElevation: 100,
            showHorizon: $showHorizon
        )
    }
}
