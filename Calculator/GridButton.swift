//
//  GridButton.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

import SwiftUI


struct GridButton: Identifiable {
    let id = UUID()
    let spec: KeySpec
    let gridRow: Int
    let gridCol: Int
    let width: CGFloat
    let height: CGFloat
}
