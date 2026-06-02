//
//  ButtonGridView.swift
//  Calculator
//
//  Created by Peter Harding on 2026-06-02.
//

import SwiftUI


// ---------------------------------------------------------------------------

struct ButtonGridView: View {
    let keys: [[KeySpec]]
    let totalButtonRows: Int
    let totalButtonColumns: Int
    let buttonSize: CGFloat
    let buttonSpacing: CGFloat
    let buttonTapped: (CalculatorButton) -> Void
    var displayPrecision: Int? = nil
    
    // Compute all button positions in the grid
    private var gridButtons: [GridButton] {
        var occupied = Array(repeating: Array(repeating: false, count: totalButtonColumns), count: totalButtonRows)
        var buttons: [GridButton] = []
        
        for rowIndex in 0..<keys.count {
            var col = 0
            
            for spec in keys[rowIndex] {
                // Skip occupied columns
                while col < totalButtonColumns && occupied[rowIndex][col] {
                    col += 1
                }
                
                // Safety check
                guard col < totalButtonColumns else { break }
                
                let spanCols = spec.span.cols
                let spanRows = spec.span.rows
                let w = CGFloat(spanCols) * buttonSize + CGFloat(max(0, spanCols - 1)) * buttonSpacing
                let h = CGFloat(spanRows) * buttonSize + CGFloat(max(0, spanRows - 1)) * buttonSpacing
                
                // Create button at this position
                buttons.append(GridButton(
                    spec: spec,
                    gridRow: rowIndex,
                    gridCol: col,
                    width: w,
                    height: h
                ))
                
                // Mark occupied cells
                for r in 0..<spanRows {
                    for c in 0..<spanCols {
                        let rr = rowIndex + r
                        let cc = col + c
                        if rr < totalButtonRows && cc < totalButtonColumns {
                            occupied[rr][cc] = true
                        }
                    }
                }
                
                col += spanCols
            }
        }
        
        return buttons
    }
    
    var body: some View {
        let buttons = gridButtons
        let baseOffset = buttonSize + buttonSpacing
        
        ZStack(alignment: .topLeading) {
            ForEach(buttons) { button in
                let xOffset = CGFloat(button.gridCol) * baseOffset
                let yOffset = CGFloat(button.gridRow) * baseOffset
                
                if button.spec.button != .blank {
                    CalculatorButtonView(
                        button: button.spec.button,
                        size: buttonSize,
                        width: button.width,
                        height: button.height,
                        displayPrecision: displayPrecision
                    ) {
                        buttonTapped(button.spec.button)
                    }
                    .offset(x: xOffset, y: yOffset)
                } else {
                    Color.clear
                        .frame(width: button.width, height: button.height)
                        .offset(x: xOffset, y: yOffset)
                }
            }
        }
        .frame(
            width: CGFloat(totalButtonColumns) * buttonSize + CGFloat(totalButtonColumns - 1) * buttonSpacing,
            height: CGFloat(totalButtonRows) * buttonSize + CGFloat(totalButtonRows - 1) * buttonSpacing,
            alignment: .topLeading
        )
    }
}


// ---------------------------------------------------------------------------
