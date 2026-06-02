//
//  CalculatorButtonView.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

import SwiftUI

// ---------------------------------------------------------------------------


struct CalculatorButtonView: View {
    let button: CalculatorButton
    let size: CGFloat
    let width: CGFloat?
    let height: CGFloat?
    var displayPrecision: Int? = nil
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .frame(width: width ?? size, height: height ?? size)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var title: String {
        switch button {
        case .digit(let n): return n
        case .dot: return "."
        case .operation(let op): return op
        case .equals: return "="
        case .clearEntry: return "CE"
        case .clear: return "C"
        case .backspace: return "⌫"
        case .memory(let m): return m
        case .toggleSign: return "±"
        case .precision: 
            if let precision = displayPrecision {
                return ".\(precision)"
            } else {
                return "Prec"
            }
        case .blank: return ""
        }
    }
    
    private var backgroundColor: Color {
        switch button {
        case .operation, .equals: return Color.gray.opacity(0.8)
        case .clear: return Color.orange
        case .clearEntry: return Color.yellow
        case .backspace: return Color.gray.opacity(0.6)
        case .memory: return Color.gray.opacity(0.5)
        case .precision: return Color.blue.opacity(0.6)
        case .toggleSign, .digit, .dot: return Color(white: 0.3)
        case .blank: return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch button {
        case .clear, .clearEntry: return .black
        case .digit, .dot, .toggleSign, .equals, .precision: return .white
        default: return .black
        }
    }
}



//struct CalculatorButtonView: View {
//    let button: CalculatorButton
//    let size: CGFloat
//    let width: CGFloat?
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Text(buttonTitle)
//                .font(.system(size: 26, weight: .semibold))
//                .frame(width: width ?? size, height: size)
//                .background(buttonBackground)
//                .foregroundColor(buttonForeground)
//                .cornerRadius(8)
//        }
//        .disabled(button == .blank)
//        .opacity(button == .blank ? 0 : 1)
//    }
//
//    var buttonTitle: String {
//        switch button {
//        case .digit(let n): return n
//        case .operation(let op): return op
//        case .equals: return "="
//        case .dot: return "."
//        case .clearEntry: return "CE"
//        case .clear: return "C"
//        case .backspace: return "⌫"
//        case .memory(let m): return m
//        case .toggleSign: return "+/-"
//        case .blank: return ""
//        }
//    }
//
//    var buttonBackground: Color {
//        switch button {
//        case .clear: return Color.orange
//        case .clearEntry: return Color.yellow
//        case .operation, .equals: return Color.gray.opacity(0.8)
//        case .memory: return Color.gray.opacity(0.5)
//        case .digit, .toggleSign: return Color(white: 0.3)
//        case .backspace: return Color.gray.opacity(0.6)
//        case .dot: return Color(white: 0.3)
//        case .blank: return Color.clear
//        }
//    }
//
//    var buttonForeground: Color {
//        switch button {
//        case .clear, .clearEntry: return .black
//        case .digit, .dot, .toggleSign: return .white
//        case .equals: return .white
//        default: return .black
//        }
//    }
//}

// ---------------------------------------------------------------------------
