//
//  HUDControlsView.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI
import AVFoundation

struct HUDControlsView: View
{
    @Binding var selectedCamera: AVCaptureDevice.Position
    @Binding var showPOIList: Bool
    @Binding var showCompass: Bool
    @Binding var showHorizon: Bool
    @Binding var showFilterSheet: Bool
    @Binding var showRadarView: Bool
    
    let selectedPOITypes: Set<POIType>
    let maxPOIDistance: Double
    let maxListDistance: Double
    
    var body: some View
    {
        HStack(spacing: 20)
        {
            // Switch camera button
            Button
            {
                selectedCamera = selectedCamera == .back ? .front : .back
            }
        label:
            {
                Image(systemName: "camera.rotate")
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Toggle POI list button
            Button
            {
                withAnimation
                {
                    showPOIList.toggle()
                }
            }
            label:
            {
                Image(systemName: showPOIList ? "list.bullet.circle.fill" : "list.bullet.circle")
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            // Toggle compass button
            Button
            {
                withAnimation
                {
                    showCompass.toggle()
                }
            }
            label:
            {
                Image(systemName: showCompass ? "map.circle.fill" : "map.circle")
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            // Toggle horizon line button
            Button
            {
                withAnimation
                {
                    showHorizon.toggle()
                }
            }
            label:
            {
                Image(systemName: showHorizon ? "sun.horizon.fill" : "sun.horizon")
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            // Show radar view button
            Button
            {
                showRadarView = true
            }
            label:
            {
                Image(systemName: "target")
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            // Filter POI types button
            Button
            {
                showFilterSheet = true
            }
            label:
            {
                ZStack(alignment: .topTrailing)
                {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.body)
                        .foregroundStyle(.black)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                    
                    // Badge showing filter is active
                    if selectedPOITypes.count < POIType.allCases.count || 
                       maxPOIDistance != 100_000 || maxListDistance != 50_000
                    {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: 2)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}

#Preview
{
    @Previewable @State var selectedCamera: AVCaptureDevice.Position = .back
    @Previewable @State var showPOIList = false
    @Previewable @State var showCompass = true
    @Previewable @State var showHorizon = true
    @Previewable @State var showFilterSheet = false
    @Previewable @State var showRadarView = false
    
    HUDControlsView(
        selectedCamera: $selectedCamera,
        showPOIList: $showPOIList,
        showCompass: $showCompass,
        showHorizon: $showHorizon,
        showFilterSheet: $showFilterSheet,
        showRadarView: $showRadarView,
        selectedPOITypes: Set(POIType.allCases),
        maxPOIDistance: 100_000,
        maxListDistance: 50_000
    )
}
