//
//  KeySpec.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

import SwiftUI

// ---------------------------------------------------------------------------

struct KeySpec: Identifiable, Equatable {
    let id = UUID()
    let button: CalculatorButton
    let span: ButtonSpan
    
    static func == (lhs: KeySpec, rhs: KeySpec) -> Bool {
        lhs.button == rhs.button && lhs.span == rhs.span
    }
}

// ---------------------------------------------------------------------------
