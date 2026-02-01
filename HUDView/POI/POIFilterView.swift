//
//  POIFilterView.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI

/// View for filtering POI types and distance range
struct POIFilterView: View {
    @Binding var selectedTypes: Set<POIType>
    @Binding var maxDistance: Double
    @Binding var maxListDistance: Double
    @Binding var distanceUnit: HUDSettings.DistanceUnit
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Distance Unit Section
                Section {
                    Picker("Distance Unit", selection: $distanceUnit) {
                        ForEach(HUDSettings.DistanceUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Distance Unit")
                } footer: {
                    Text("Choose whether to display distances in kilometers or miles")
                }
                
                // Distance Range Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overlay POIs Range")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        // Scrollable horizontal picker for distance presets
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(HUDSettings.DistanceUnit.distancePresets, id: \.self) { distance in
                                    DistanceButton(
                                        distance: distance,
                                        currentDistance: maxDistance,
                                        distanceUnit: distanceUnit
                                    ) {
                                        maxDistance = distance
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Text("Maximum distance for POIs shown on camera overlay")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nearby List Range")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        // Scrollable horizontal picker for list distance presets
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(HUDSettings.DistanceUnit.distancePresets, id: \.self) { distance in
                                    DistanceButton(
                                        distance: distance,
                                        currentDistance: maxListDistance,
                                        distanceUnit: distanceUnit
                                    ) {
                                        maxListDistance = distance
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Text("Maximum distance for POIs shown in nearby list")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Distance Range")
                } footer: {
                    Text("Scroll horizontally to see all distance options")
                }
                
                // POI Categories Section
                Section("POI Categories") {
                    ForEach(POIType.allCases, id: \.self) { type in
                        POIFilterRow(
                            type: type,
                            isSelected: selectedTypes.contains(type)
                        ) {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        }
                    }
                }
                
                // Quick Actions Section
                Section {
                    Button("Select All Categories") {
                        selectedTypes = Set(POIType.allCases)
                    }
                    
                    Button("Deselect All Categories") {
                        selectedTypes.removeAll()
                    }
                    
                    Button("Reset to Defaults") {
                        selectedTypes = [.city, .mountain, .bridge, .park]
                        maxDistance = 100_000
                        maxListDistance = 50_000
                    }
                }
            }
            .navigationTitle("Filter POIs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            // Snap to nearest preset if current value isn't already a preset
            maxDistance = snapToNearestPreset(maxDistance)
            maxListDistance = snapToNearestPreset(maxListDistance)
        }
    }
    
    /// Snap a distance value to the nearest preset
    private func snapToNearestPreset(_ distance: Double) -> Double {
        let presets = HUDSettings.DistanceUnit.distancePresets
        
        // If already a preset, return as-is
        if presets.contains(distance) {
            return distance
        }
        
        // Find nearest preset
        return presets.min(by: { abs($0 - distance) < abs($1 - distance) }) ?? distance
    }
    
    /// Check if a distance matches a preset (with tolerance for floating point comparison)
    private func isSelected(_ distance: Double, current: Double) -> Bool {
        abs(distance - current) < 1.0 // Within 1 meter tolerance
    }
}

/// A button for selecting distance presets with proper state tracking
struct DistanceButton: View {
    let distance: Double
    let currentDistance: Double
    let distanceUnit: HUDSettings.DistanceUnit
    let action: () -> Void
    
    private var isSelected: Bool {
        abs(distance - currentDistance) < 1.0
    }
    
    var body: some View {
        Text(distanceUnit.formatPreset(meters: distance))
            .font(.callout)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color.secondary.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
    }
}

/// Individual row for POI filter
struct POIFilterRow: View {
    let type: POIType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                    .foregroundStyle(colorForType)
                    .frame(width: 30)
                
                Text(type.displayName)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
    
    private var colorForType: Color {
        switch type.color {
        case "orange": return .orange
        case "brown": return .brown
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "mint": return .mint
        case "cyan": return .cyan
        case "purple": return .purple
        default: return .gray
        }
    }
}

#Preview {
    @Previewable @State var selectedTypes: Set<POIType> = [.city, .mountain, .bridge]
    @Previewable @State var maxDistance: Double = 100_000
    @Previewable @State var maxListDistance: Double = 50_000
    @Previewable @State var distanceUnit: HUDSettings.DistanceUnit = .metric
    
    POIFilterView(
        selectedTypes: $selectedTypes,
        maxDistance: $maxDistance,
        maxListDistance: $maxListDistance,
        distanceUnit: $distanceUnit
    )
}
