//
//  ContentView.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

import SwiftUI

// ---------------------------------------------------------------------------

struct ContentView: View {
    @State private var display: String = "0"
    @State private var accumulator: Double = 0
    @State private var pendingOperator: String? = nil
    @State private var lastInputWasOperator = false
    @State private var memory: Double = 0
    @State private var keyPressed: String = ""
    @State private var displayPrecision: Int? = nil // nil means no precision limit
    @State private var orientation = UIDeviceOrientation.unknown


    let totalButtonColumns = 6
    let totalButtonRows = 5

    // Define the keys with spans. Row/column indices are 0-based in this matrix.
    let keys: [[KeySpec]] = [
        [
            KeySpec(button: .precision, span: .init()),
            KeySpec(button: .memory("MC"), span: .init()),
            KeySpec(button: .memory("MR"), span: .init()),
            KeySpec(button: .memory("M-"), span: .init()),
            KeySpec(button: .memory("M+"), span: .init()),
            KeySpec(button: .operation("√"), span: .init())
        ],
        [
            KeySpec(button: .toggleSign, span: .init()),
            KeySpec(button: .digit("7"), span: .init()),
            KeySpec(button: .digit("8"), span: .init()),
            KeySpec(button: .digit("9"), span: .init()),
            KeySpec(button: .operation("*"), span: .init()),
            KeySpec(button: .operation("%"), span: .init())
        ],
        [
            // C at its current position (row 2, col 0) spanning 2 rows
            KeySpec(button: .clear, span: .init(rows: 2)),
            KeySpec(button: .digit("4"), span: .init()),
            KeySpec(button: .digit("5"), span: .init()),
            KeySpec(button: .digit("6"), span: .init()),
            KeySpec(button: .operation("-"), span: .init()),
            KeySpec(button: .operation("/"), span: .init())
        ],
        [
            // Row 3: Column 0 is occupied by C's span from row 2
            KeySpec(button: .digit("1"), span: .init()),
            KeySpec(button: .digit("2"), span: .init()),
            KeySpec(button: .digit("3"), span: .init()),
            // '+' starting here (row 3, col 3) spanning 2 rows
            KeySpec(button: .operation("+"), span: .init(rows: 2)),
            // '=' starting here (row 3, col 4) spanning 2 rows
            KeySpec(button: .equals, span: .init(rows: 2))
        ],
        [
            KeySpec(button: .backspace, span: .init()),
            // 0 double width
            KeySpec(button: .digit("0"), span: .init(cols: 2)),
            KeySpec(button: .dot, span: .init())
            // Columns 4 and 5 are occupied by '+' and '=' spanning from row 3
        ]
    ]

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let buttonSpacing: CGFloat = 12
            // Use defined totalButtonColumns and totalButtonRows constants
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
                        ButtonGridView(
                            keys: keys,
                            totalButtonRows: totalButtonRows,
                            totalButtonColumns: totalButtonColumns,
                            buttonSize: buttonSize,
                            buttonSpacing: buttonSpacing,
                            buttonTapped: buttonTapped,
                            displayPrecision: displayPrecision
                        )
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
                        ButtonGridView(
                            keys: keys,
                            totalButtonRows: totalButtonRows,
                            totalButtonColumns: totalButtonColumns,
                            buttonSize: buttonSize,
                            buttonSpacing: buttonSpacing,
                            buttonTapped: buttonTapped,
                            displayPrecision: displayPrecision
                        )
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
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
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
            // Handle unary operations (square root)
            if op == "√" {
                if let value = Double(display) {
                    if value < 0 {
                        display = "Error"
                    } else {
                        let result = sqrt(value)
                        display = formatNumber(result)
                    }
                }
                lastInputWasOperator = false
            } else {
                // Handle binary operations
                computePending()
                pendingOperator = op
                accumulator = Double(display) ?? 0
                lastInputWasOperator = true
            }
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
        case .toggleSign:
            if let value = Double(display) {
                let toggled = -value
                display = formatNumber(toggled)
            }
            lastInputWasOperator = false
        case .precision:
            // Set display precision based on current display value
            if let precisionValue = Int(display) {
                if precisionValue >= 0 && precisionValue <= 15 {
                    displayPrecision = precisionValue
                } else if precisionValue < 0 {
                    displayPrecision = 0
                } else {
                    displayPrecision = 15
                }
            }
            display = "0"
            lastInputWasOperator = false
        case .blank:
            break
        }
    }
    
    // Format number based on precision setting
    func formatNumber(_ value: Double) -> String {
        if let precision = displayPrecision {
            return String(format: "%.\(precision)f", value)
        } else {
            // No precision set - preserve integer formatting if possible
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int(value))
            } else {
                return String(value)
            }
        }
    }

    func computePending() {
        guard let op = pendingOperator, let rhs = Double(display) else { return }
        let lhs = accumulator
        let result: Double
        switch op {
        case "+": result = lhs + rhs
        case "-": result = lhs - rhs
        case "*": result = lhs * rhs
        case "/":
            if rhs == 0 {
                display = "Error"
                return
            }
            result = lhs / rhs
        case "%":
            // Calculate percentage: lhs % rhs = (lhs / rhs) * 100
            // Example: 5 % 10 = (5 / 10) * 100 = 50
            if rhs == 0 {
                display = "Error"
                return
            }
            result = (lhs / rhs) * 100
        default:
            return
        }
        display = formatNumber(result)
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


// ---------------------------------------------------------------------------



// ---------------------------------------------------------------------------

#Preview {
    ContentView()
}
