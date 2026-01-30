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
    @State private var selectedCamera: AVCaptureDevice.Position = .back
    @State private var visiblePOIs: [POIVisibilityService.VisiblePOI] = []
    @State private var nearbyPOIs: [POIVisibilityService.VisiblePOI] = []
    @State private var showPOIList = false
    @State private var showCompass = true
    @State private var showFilterSheet = false
    @State private var selectedPOITypes: Set<POIType> = Set(POIType.allCases)
    @State private var maxPOIDistance: Double = 100_000
    @State private var maxListDistance: Double = 50_000
    @State private var showHorizon = true
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
                    CameraView(cameraPosition: selectedCamera)
                        .id(selectedCamera) // Forces view recreation when camera changes
                } else {
                    Color.black
                }
                
                // HUD overlay
                VStack {
                    // Compass bearing indicator at top
                    if showCompass, let heading = locationManager.trueHeading, locationManager.isAuthorized {
                        CompassBearingView(currentHeading: heading)
                            .transition(.move(edge: .top))
                    }
                    
                    // POI list (optional)
                    if showPOIList && !nearbyPOIs.isEmpty && locationManager.isAuthorized {
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
                        showHorizon: $showHorizon
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
                selectedCamera: $selectedCamera,
                showPOIList: $showPOIList,
                showCompass: $showCompass,
                showHorizon: $showHorizon,
                showFilterSheet: $showFilterSheet,
                selectedPOITypes: selectedPOITypes,
                maxPOIDistance: maxPOIDistance,
                maxListDistance: maxListDistance
            )
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showFilterSheet) {
            POIFilterView(
                selectedTypes: $selectedPOITypes,
                maxDistance: $maxPOIDistance,
                maxListDistance: $maxListDistance
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
        .onChange(of: selectedPOITypes) { _, _ in
            updatePOIs()
        }
        .onChange(of: maxPOIDistance) { _, _ in
            updatePOIs()
        }
        .onChange(of: maxListDistance) { _, _ in
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
            maxDistance: maxPOIDistance,
            limit: 10,
            typeFilter: selectedPOITypes
        )
        
        // Update nearby POIs for the list
        nearbyPOIs = POIVisibilityService.nearestPOIs(
            from: location,
            maxDistance: maxListDistance,
            limit: 10,
            typeFilter: selectedPOITypes
        )
    }
}

#Preview {
    HUDView()
}
