//
//  CalculatorButton.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

// ---------------------------------------------------------------------------
// Calculator button types and appearance
// ---------------------------------------------------------------------------

enum CalculatorButton: Equatable {
    case digit(String)
    case operation(String)
    case equals
    case dot
    case clearEntry
    case clear
    case backspace
    case memory(String)
    case toggleSign
    case precision
    case blank
}

// ---------------------------------------------------------------------------
