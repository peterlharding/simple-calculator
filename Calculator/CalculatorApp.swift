//
//  CalculatorApp.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

import SwiftUI

// ---------------------------------------------------------------------------

@main
struct CalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Enable all orientations
                    #if os(iOS)
                    UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
                    #endif
                }
        }
    }
}

// ---------------------------------------------------------------------------
