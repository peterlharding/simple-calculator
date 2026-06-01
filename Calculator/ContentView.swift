//
//  ContentView.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

import SwiftUI

struct ContentView: View {
    @State private var display: String = "0"
    @State private var accumulator: Double = 0
    @State private var pendingOperator: String? = nil
    @State private var lastInputWasOperator = false
    @State private var memory: Double = 0
    @State private var keyPressed: String = ""

    let buttons: [[CalculatorButton]] = [
        [.memory("M+"), .memory("M-"), .memory("MR"), .memory("MC"), .backspace],
        [.digit("7"), .digit("8"), .digit("9"), .operation("/"), .clearEntry],
        [.digit("4"), .digit("5"), .digit("6"), .operation("*"), .clear],
        [.digit("1"), .digit("2"), .digit("3"), .operation("-"), .blank],
        [.digit("0"), .dot, .equals, .operation("+"), .blank]
    ]

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let buttonSpacing: CGFloat = 12
            let totalButtonColumns = 5
            let totalButtonRows = 5

            let buttonSize: CGFloat = isLandscape
                ? (geometry.size.height - 60 - 32 - buttonSpacing * CGFloat(totalButtonRows - 1)) / CGFloat(totalButtonRows)
                : (geometry.size.width - 32 - buttonSpacing * CGFloat(totalButtonColumns - 1)) / CGFloat(totalButtonColumns)

            Group {
                if isLandscape {
                    HStack(spacing: 24) {
                        // Display area
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text(display)
                                    .font(.system(size: 44, weight: .bold, design: .monospaced))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .padding(.horizontal)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.92)))
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.4)
                        // Button grid
                        VStack(spacing: buttonSpacing) {
                            let rowArray = Array(buttons.enumerated())
                            ForEach(rowArray, id: \.0) { rowIndex, rowButtons in
                                let colArray = Array(rowButtons.enumerated())
                                HStack(spacing: buttonSpacing) {
                                    if rowIndex == buttons.count - 1 {
                                        // Custom layout for last row: make "0" double-width and move "=" to the far right
                                        let spacing = buttonSpacing
                                        // Identify buttons in the row
                                        let zero = CalculatorButton.digit("0")
                                        let dot = CalculatorButton.dot
                                        let plus = CalculatorButton.operation("+")
                                        let equals = CalculatorButton.equals

                                        CalculatorButtonView(button: zero, size: buttonSize, width: buttonSize * 2 + spacing) { buttonTapped(zero) }
                                        CalculatorButtonView(button: dot, size: buttonSize, width: nil) { buttonTapped(dot) }
                                        CalculatorButtonView(button: plus, size: buttonSize, width: nil) { buttonTapped(plus) }
                                        CalculatorButtonView(button: equals, size: buttonSize, width: nil) { buttonTapped(equals) }
                                    } else {
                                        ForEach(colArray, id: \.0) { colIndex, button in
                                            CalculatorButtonView(button: button, size: buttonSize, width: nil) { buttonTapped(button) }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 0.55)
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        // Display area
                        HStack {
                            Spacer()
                            Text(display)
                                .font(.system(size: 44, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .padding(.horizontal)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.92)))
                        }
                        .padding(.horizontal)

                        // Button grid
                        VStack(spacing: buttonSpacing) {
                            let rowArray = Array(buttons.enumerated())
                            ForEach(rowArray, id: \.0) { rowIndex, rowButtons in
                                let colArray = Array(rowButtons.enumerated())
                                HStack(spacing: buttonSpacing) {
                                    if rowIndex == buttons.count - 1 {
                                        // Custom layout for last row: make "0" double-width and move "=" to the far right
                                        let spacing = buttonSpacing
                                        // Identify buttons in the row
                                        let zero = CalculatorButton.digit("0")
                                        let dot = CalculatorButton.dot
                                        let plus = CalculatorButton.operation("+")
                                        let equals = CalculatorButton.equals

                                        CalculatorButtonView(button: zero, size: buttonSize, width: buttonSize * 2 + spacing) { buttonTapped(zero) }
                                        CalculatorButtonView(button: dot, size: buttonSize, width: nil) { buttonTapped(dot) }
                                        CalculatorButtonView(button: plus, size: buttonSize, width: nil) { buttonTapped(plus) }
                                        CalculatorButtonView(button: equals, size: buttonSize, width: nil) { buttonTapped(equals) }
                                    } else {
                                        ForEach(colArray, id: \.0) { colIndex, button in
                                            CalculatorButtonView(button: button, size: buttonSize, width: nil) { buttonTapped(button) }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }

            // Hidden TextField to capture keyboard input
            TextField("", text: $keyPressed)
                .frame(width: 0, height: 0)
                .opacity(0.01)
                .onChange(of: keyPressed) { oldValue, newValue in
                    if let lastKey = newValue.last {
                        handleKeyPress(String(lastKey))
                        keyPressed = ""
                    }
                }
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
        }
        .background(Color(white: 0.8).ignoresSafeArea())
    }

    // Calculator actions
    func buttonTapped(_ button: CalculatorButton) {
        print("\(button)")
        switch button {
        case .digit(let n):
            if display == "0" || lastInputWasOperator { display = n } else { display += n }
            lastInputWasOperator = false
        case .dot:
            if !display.contains(".") { display += display == "0" ? "." : "." }
            lastInputWasOperator = false
        case .operation(let op):
            computePending()
            pendingOperator = op
            accumulator = Double(display) ?? 0
            lastInputWasOperator = true
        case .equals:
            computePending()
            pendingOperator = nil
            lastInputWasOperator = true
        case .clearEntry:
            display = "0"
        case .clear:
            display = "0"
            accumulator = 0
            pendingOperator = nil
            lastInputWasOperator = false
        case .backspace:
            if display.count > 1 { display.removeLast() } else { display = "0" }
        case .memory(let m):
            switch m {
            case "M+": memory += Double(display) ?? 0
            case "M-": memory -= Double(display) ?? 0
            case "MR": display = String(memory)
            case "MC": memory = 0
            default: break
            }
        case .blank:
            break
        }
    }

    func computePending() {
        guard let op = pendingOperator, let rhs = Double(display) else { return }
        let lhs = accumulator
        switch op {
        case "+": display = String(lhs + rhs)
        case "-": display = String(lhs - rhs)
        case "*": display = String(lhs * rhs)
        case "/":
            display = rhs == 0 ? "Error" : String(lhs / rhs)
        default: break
        }
    }
    
    func handleKeyPress(_ key: String) {
        let k = key.lowercased()

        if k == "m" {
            buttonTapped(.memory("MR"))
            return
        }

        switch k {
        case "0","1","2","3","4","5","6","7","8","9":
            buttonTapped(.digit(k))
        case ".", ",":
            buttonTapped(.dot)
        case "+", "-", "*", "/":
            buttonTapped(.operation(k))
        case "=", "\r", "\n":
            buttonTapped(.equals)
        case "c":
            buttonTapped(.clear)
        case "\u{8}", "\u{7f}": // backspace and delete
            buttonTapped(.backspace)
        default:
            break
        }
    }
}

// Calculator button types and appearance
enum CalculatorButton: Equatable {
    case digit(String)
    case operation(String)
    case equals
    case dot
    case clearEntry
    case clear
    case backspace
    case memory(String)
    case blank
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let size: CGFloat
    let width: CGFloat?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(buttonTitle)
                .font(.system(size: 26, weight: .semibold))
                .frame(width: width ?? size, height: size)
                .background(buttonBackground)
                .foregroundColor(buttonForeground)
                .cornerRadius(8)
        }
        .disabled(button == .blank)
        .opacity(button == .blank ? 0 : 1)
    }

    var buttonTitle: String {
        switch button {
        case .digit(let n): return n
        case .operation(let op): return op
        case .equals: return "="
        case .dot: return "."
        case .clearEntry: return "CE"
        case .clear: return "C"
        case .backspace: return "⌫"
        case .memory(let m): return m
        case .blank: return ""
        }
    }

    var buttonBackground: Color {
        switch button {
        case .clear: return Color.orange
        case .clearEntry: return Color.yellow
        case .operation, .equals: return Color.gray.opacity(0.8)
        case .memory: return Color.gray.opacity(0.5)
        case .digit: return Color(white: 0.3)
        case .backspace: return Color.gray.opacity(0.6)
        case .dot: return Color(white: 0.3)
        case .blank: return Color.clear
        }
    }

    var buttonForeground: Color {
        switch button {
        case .clear, .clearEntry: return .black
        case .digit, .dot: return .white
        case .equals: return .white
        default: return .black
        }
    }
}

#Preview {
    ContentView()
}
