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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Distance Range Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overlay POIs Range")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text(formatDistance(maxDistance))
                                .font(.headline)
                                .frame(minWidth: 80, alignment: .leading)
                            
                            Slider(value: $maxDistance, in: 1000...10_000_000, step: 1000)
                            
                            Button {
                                maxDistance = 100_000 // Reset to default
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.caption)
                            }
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
                        
                        HStack {
                            Text(formatDistance(maxListDistance))
                                .font(.headline)
                                .frame(minWidth: 80, alignment: .leading)
                            
                            Slider(value: $maxListDistance, in: 1000...10_000_000, step: 1000)
                            
                            Button {
                                maxListDistance = 50_000 // Reset to default
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.caption)
                            }
                        }
                        
                        Text("Maximum distance for POIs shown in nearby list")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    // Quick distance presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach([10_000.0, 50_000.0, 100_000.0, 500_000.0, 1_000_000.0, 5_000_000.0, 10_000_000.0], id: \.self) { distance in
                                Button {
                                    maxDistance = distance
                                    maxListDistance = min(distance, 1_000_000)
                                } label: {
                                    Text(formatDistanceShort(distance))
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(maxDistance == distance ? Color.blue : Color.secondary.opacity(0.2))
                                        .foregroundStyle(maxDistance == distance ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Distance Range")
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.0f km", meters / 1000)
        }
    }
    
    private func formatDistanceShort(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0fm", meters)
        } else {
            return String(format: "%.0fkm", meters / 1000)
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
    
    POIFilterView(
        selectedTypes: $selectedTypes,
        maxDistance: $maxDistance,
        maxListDistance: $maxListDistance
    )
}
