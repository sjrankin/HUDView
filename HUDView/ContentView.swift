//
//  ContentView.swift
//  HUDView
//
//  Created by Stuart Rankin on 1/30/26.
//

import SwiftUI

struct ContentView: View
{
    var body: some View
    {
        HUDView()
            .ignoresSafeArea() // Ensure full-screen camera in all orientations
    }
}

#Preview
{
    ContentView()
}
