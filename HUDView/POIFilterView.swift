//
//  POIFilterView.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI

/// View for filtering POI types
struct POIFilterView: View {
    @Binding var selectedTypes: Set<POIType>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
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
                
                Section {
                    Button("Select All") {
                        selectedTypes = Set(POIType.allCases)
                    }
                    
                    Button("Deselect All") {
                        selectedTypes.removeAll()
                    }
                    
                    Button("Reset to Default") {
                        selectedTypes = [.city, .mountain, .bridge, .park]
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
    
    POIFilterView(selectedTypes: $selectedTypes)
}
