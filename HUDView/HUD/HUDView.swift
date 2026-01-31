//
//  HUDView.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI
import AVFoundation
import CoreLocation

struct HUDView: View {
    @State private var cameraManager = CameraManager()
    @State private var locationManager = LocationManager()
    @State private var settings = HUDSettings.shared
    @State private var visiblePOIs: [POIVisibilityService.VisiblePOI] = []
    @State private var nearbyPOIs: [POIVisibilityService.VisiblePOI] = []
    @State private var showFilterSheet = false
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Camera view with overlays
            ZStack {
                // Camera preview background
                if cameraManager.isAuthorized {
                    CameraView(cameraPosition: settings.selectedCamera)
                        .id(settings.selectedCamera) // Forces view recreation when camera changes
                } else {
                    Color.black
                }
                
                // HUD overlay
                VStack {
                    // Compass bearing indicator at top
                    if settings.showCompass, let heading = locationManager.trueHeading, locationManager.isAuthorized {
                        CompassBearingView(currentHeading: heading)
                            .transition(.move(edge: .top))
                    }
                    
                    // POI list (optional)
                    if settings.showPOIList && !nearbyPOIs.isEmpty && locationManager.isAuthorized {
                        POIListView(pois: nearbyPOIs)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    // Info panel with compass and coordinates
                    if locationManager.isAuthorized {
                        HUDInfoPanel(
                            heading: locationManager.trueHeading,
                            compassDirection: locationManager.compassDirection,
                            latitude: locationManager.latitude,
                            longitude: locationManager.longitude,
                            altitude: locationManager.altitude
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                
                // Horizon line overlay
                if locationManager.isAuthorized, let heading = locationManager.trueHeading {
                    HorizonLineWithLabel(
                        currentHeading: heading,
                        userElevation: locationManager.altitude,
                        showHorizon: $settings.showHorizon
                    )
                    .allowsHitTesting(false)
                }
                
                // POI markers overlaid on camera view (directional points with elevation correction)
                if locationManager.isAuthorized && !visiblePOIs.isEmpty {
                    POIOverlayView(
                        visiblePOIs: visiblePOIs,
                        userElevation: locationManager.altitude
                    )
                    .allowsHitTesting(false)
                }
                
                // Permission request overlay
                if !cameraManager.isAuthorized {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                        
                        Text("Camera Access Required")
                            .font(.title2)
                            .foregroundStyle(.white)
                        
                        Text("Please allow access to the camera to use this feature.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal)
                        
                        Button("Allow Camera Access") {
                            Task {
                                await cameraManager.requestPermission()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            
            // Controls view below camera
            HUDControlsView(
                selectedCamera: $settings.selectedCamera,
                showPOIList: $settings.showPOIList,
                showCompass: $settings.showCompass,
                showHorizon: $settings.showHorizon,
                showFilterSheet: $showFilterSheet,
                selectedPOITypes: settings.selectedPOITypes,
                maxPOIDistance: settings.maxPOIDistance,
                maxListDistance: settings.maxListDistance
            )
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showFilterSheet) {
            POIFilterView(
                selectedTypes: $settings.selectedPOITypes,
                maxDistance: $settings.maxPOIDistance,
                maxListDistance: $settings.maxListDistance,
                distanceUnit: $settings.distanceUnit
            )
        }
        .task {
            // Request camera permission
            if cameraManager.authorizationStatus == .notDetermined {
                await cameraManager.requestPermission()
            }
            
            // Request location permission and start updates
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestPermission()
            }
            
            if locationManager.isAuthorized {
                locationManager.startUpdating()
            }
        }
        .onChange(of: locationManager.currentLocation) { _, _ in
            updatePOIs()
        }
        .onChange(of: locationManager.trueHeading) { _, _ in
            updatePOIs()
        }
        .onChange(of: settings.selectedPOITypes) { _, _ in
            updatePOIs()
        }
        .onChange(of: settings.maxPOIDistance) { _, _ in
            updatePOIs()
        }
        .onChange(of: settings.maxListDistance) { _, _ in
            updatePOIs()
        }
        .onDisappear {
            locationManager.stopUpdating()
        }
    }
    
    private func updatePOIs() {
        guard let location = locationManager.currentLocation?.coordinate,
              let heading = locationManager.trueHeading else {
            return
        }
        
        // Update visible POIs based on camera direction
        visiblePOIs = POIVisibilityService.visiblePOIs(
            from: location,
            heading: heading,
            fieldOfView: 60,
            maxDistance: settings.maxPOIDistance,
            limit: 10,
            typeFilter: settings.selectedPOITypes
        )
        
        // Update nearby POIs for the list
        nearbyPOIs = POIVisibilityService.nearestPOIs(
            from: location,
            maxDistance: settings.maxListDistance,
            limit: 10,
            typeFilter: settings.selectedPOITypes
        )
    }
}

#Preview {
    HUDView()
}
