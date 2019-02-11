//
//  BoardCell.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/3/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation
import SpriteKit

/// Representation of a square on the board enclosed by dots
public class BoardCell {
    
    private let borderDots: [Dot] // An array of the dots enclosing this square
    
    public let num: Int // The ordered number of this square on the board
    public var score = Int.random(in: 1...5) // Randomly assigned score for this square
    
    public var top    = false // Is the top closed?
    public var right  = false // The right closed?
    public var bottom = false // The Bottom?
    public var left   = false // Left?
    
    init(num: Int, borderDots: [Dot]) {
        self.borderDots = borderDots
        self.num = num
    }
    
    /// Getter that returns the dots enclosing this square
    public func getBorderDots() -> [Dot] {
        return borderDots
    }
    
    /// Helper function for producing an exclusive copy of this square
    ///
    /// - Returns: The copy of this square
    public func copy() -> BoardCell {
        var copyBorderDots = [Dot]()
        for dot in borderDots {
            copyBorderDots.append(dot.copy())
        }
        let square = BoardCell(num: num, borderDots: copyBorderDots)
        square.top = top
        square.right = right
        square.bottom = bottom
        square.left = left
        square.score = score
        return square
    }
    
}
