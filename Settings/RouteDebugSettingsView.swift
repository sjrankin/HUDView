//
//  RouteDebugSettingsView.swift
//  HUDView
//
//  Created by Stuart Rankin on 2/1/26.
//

import SwiftUI

/// View for debugging and managing route POI settings
struct RouteDebugSettingsView: View
{
    @Environment(\.dismiss) var dismiss
    @State private var settings = HUDSettings.shared
    
    var body: some View
    {
        NavigationStack
        {
            List
            {
                // Route Status Section
                Section
                {
                    HStack
                    {
                        Text("Total Route Waypoints")
                        Spacer()
                        Text("\(NorthernCaliforniaData.routePOIs.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack
                    {
                        Text("Visited Waypoints")
                        Spacer()
                        Text("\(settings.visitedRoutePOIs.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack
                    {
                        Text("Remaining Waypoints")
                        Spacer()
                        Text("\(NorthernCaliforniaData.routePOIs.count - settings.visitedRoutePOIs.count)")
                            .foregroundStyle(.secondary)
                    }
                }
                header:
                {
                    Text("Route Status")
                }
                
                // Visited Waypoints Section
                if !settings.visitedRoutePOIs.isEmpty
                {
                    Section
                    {
                        ForEach(Array(settings.visitedRoutePOIs).sorted(), id: \.self)
                        {
                            name in
                            HStack
                            {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text(name)
                            }
                        }
                    }
                    header:
                    {
                        Text("Visited Waypoints")
                    }
                }
                
                // Actions Section
                Section
                {
                    Button("Reset Route Visits", role: .destructive)
                    {
                        settings.resetRouteVisits()
                    }
                    .foregroundStyle(.red)
                }
                footer:
                {
                    Text("This will reset all route POI markers to gray (unvisited state)")
                }
            }
            .navigationTitle("Route Debug Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .confirmationAction)
                {
                    Button("Done")
                    {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview
{
    RouteDebugSettingsView()
}
