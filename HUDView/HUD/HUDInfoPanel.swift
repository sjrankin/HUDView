//
//  HUDInfoPanel.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI
import CoreLocation

/// Displays compass direction and geographic coordinates in a HUD style
struct HUDInfoPanel: View
{
    let heading: Double?
    let compassDirection: String
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var isLandscape: Bool
    {
        verticalSizeClass == .compact
    }
    
    var body: some View
    {
        if isLandscape
        {
            compactLayout
        }
        else
        {
            regularLayout
        }
    }
    
    // Compact layout for landscape
    private var compactLayout: some View
    {
        HStack(spacing: 8)
        {
            // Compass icon
            Image(systemName: "location.north.fill")
                .font(.caption)
                .foregroundStyle(.red)
                .rotationEffect(.degrees(heading != nil ? -heading! : 0))
                .frame(width: 24, height: 24)
            
            // Heading - ultra compact
            HStack(spacing: 3)
            {
                Text(compassDirection)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                
                if let heading = heading {
                    Text(String(format: "%.0f°", heading))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.black.opacity(0.7))
                }
            }
            
            Divider()
                .frame(height: 30)
                .background(.black.opacity(0.2))
            
            // Coordinates - minimal
            HStack(spacing: 4)
            {
                Image(systemName: "location.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.blue)
                
                Text(formatCoordinatesCompact(latitude: latitude, longitude: longitude))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }
            
            // Altitude - minimal
            if let altitude = altitude
            {
                Divider()
                    .frame(height: 30)
                    .background(.black.opacity(0.2))
                
                HStack(spacing: 4)
                {
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.orange)
                    
                    Text(String(format: "%.0fm", altitude))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.black)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(.black.opacity(0.1), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // Regular layout for portrait
    private var regularLayout: some View
    {
        HStack(spacing: 12)
        {
            // Compass icon with rotation
            ZStack
            {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "location.north.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
                    .rotationEffect(.degrees(heading != nil ? -heading! : 0))
            }
            
            // Heading
            VStack(alignment: .leading, spacing: 2)
            {
                Text("Heading")
                    .font(.caption2)
                    .foregroundStyle(.black.opacity(0.7))
                
                HStack(alignment: .firstTextBaseline, spacing: 4)
                {
                    Text(compassDirection)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                    
                    if let heading = heading
                    {
                        Text(String(format: "%.1f°", heading))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.8))
                    }
                }
            }
            
            Divider()
                .frame(height: 40)
                .background(.black.opacity(0.2))
            
            // Coordinates section
            VStack(alignment: .leading, spacing: 4)
            {
                // Combined Lat/Lon
                HStack(spacing: 6)
                {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    
                    Text(formatCoordinates(latitude: latitude, longitude: longitude))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                // Altitude
                if let altitude = altitude
                {
                    HStack(spacing: 6)
                    {
                        Image(systemName: "mountain.2.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        
                        Text(String(format: "%.1f m", altitude))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.black)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(.black.opacity(0.1), lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private func formatCoordinates(latitude: Double?, longitude: Double?) -> String
    {
        guard let lat = latitude, let lon = longitude else
        {
            return "— , —"
        }
        return String(format: "%.4f° , %.4f°", lat, lon)
    }
    
    private func formatCoordinatesCompact(latitude: Double?, longitude: Double?) -> String
    {
        guard let lat = latitude, let lon = longitude else
        {
            return "—"
        }
        return String(format: "%.2f°,%.2f°", lat, lon)
    }
}

#Preview
{
    ZStack
    {
        Color.black.ignoresSafeArea()
        
        VStack
        {
            // With data
            HUDInfoPanel(
                heading: 45.5,
                compassDirection: "NE",
                latitude: 37.7749,
                longitude: -122.4194,
                altitude: 52.0
            )
            .padding()
            
            // Without data
            HUDInfoPanel(
                heading: nil,
                compassDirection: "—",
                latitude: nil,
                longitude: nil,
                altitude: nil
            )
            .padding()
        }
    }
}
