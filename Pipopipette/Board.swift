//
//  Board.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/3/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation
import SpriteKit

public class Board {
    public let size: Int
    private let numDots: Int
    private let numSquares: Int
    private let dots: [[Dot]]
    private let squares: [[BoardCell]]
    
    private var lastMove: (Dot, Dot)?
    private var humanScore: Int
    private var computerScore: Int
    private var original: Bool
    private var isComputerTurn = false
    
    private var ply = 0
    
    init(size: Int, with dots: [[Dot]], with squares: [[BoardCell]]) {
        self.size = size
        self.numDots = size * size
        self.numSquares = (size - 1) * (size - 1)
        self.dots = dots
        self.squares = squares
        self.humanScore = 0
        self.computerScore = 0
        original = false
    }
    
    public func copy() -> Board {
        // First, create a copy of dots
        var dotsCopy = [[Dot]]()
        for i in 0..<(size) {
            var dotRowCopy = [Dot]()
            for j in 0..<(size) {
                dotRowCopy.append(dots[i][j].copy())
                
            }
            dotsCopy.append(dotRowCopy)
        }
        // Then, create a copy of squares
        var squaresCopy = [[BoardCell]]()
        for i in 0..<(size - 1) {
            var squareRowCopy = [BoardCell]()
            for j in 0..<(size - 1) {
                squareRowCopy.append(squares[i][j].copy())
            }
            squaresCopy.append(squareRowCopy)
        }
        
        let newBoard = Board(size: size, with: dotsCopy, with: squaresCopy)
        let (dotOne, dotTwo) = lastMove!
        newBoard.updateLastMove(with: dotOne, and: dotTwo)
        newBoard.setHumanScore(to: humanScore)
        newBoard.setComputerScore(to: computerScore)
        newBoard.setPly(to: ply)
        
        return newBoard
    }
    
    public func setPly(to ply: Int) {
        self.ply = ply
    }
 
    public func initiateHumanMove(with dot: Dot, and otherDot: Dot) {
        if isComputerTurn {
            return
        }
        dot.connect(to: otherDot, as: isComputerTurn, from: original)
        updateLastMove(with: dot, and: otherDot)
        checkForSquares(from: dot, and: otherDot)
        isComputerTurn = true
        DispatchQueue.global(qos: .userInitiated).async { [ weak self] in
            guard let self = self else {
                return
            }
            self.startComputerTurn()
        }
    }
    
    public func simulateHumanMove(with dot: Dot, and otherDot: Dot) {
        isComputerTurn = false
        dot.connect(to: otherDot, as: isComputerTurn, from: false)
        updateLastMove(with: dot, and: otherDot)
        checkForSquares(from: dot, and: otherDot)
        isComputerTurn = true
    }
    
    public func initiateComputerMove(with dot: Dot, and otherDot: Dot) {
        isComputerTurn = true
        dot.connect(to: otherDot, as: isComputerTurn, from: original)
        updateLastMove(with: dot, and: otherDot)
        checkForSquares(from: dot, and: otherDot)
        isComputerTurn = false
    }
    
    public func setAsOriginal() {
        original = true
    }
    
    private func startComputerTurn() {
        print("Starting Computer Turn")
        minimax(on: self, to: ply)
        isComputerTurn = false
    }
        
    public func updateLastMove(with dot: Dot, and otherDot: Dot) {
        lastMove = (dot, otherDot)
    }
    
    public func getLastMove() -> (Dot, Dot) {
        return lastMove!
    }
    
    public func areAdjacent(this dot: Dot, that otherDot: Dot) -> Bool {
        if getAdjacents(of: dot).contains(otherDot) {
            return true
        } else {
            return false
        }
    }
    
    public func getHumanScore() -> Int {
        return humanScore
    }
    
    public func setHumanScore(to score: Int) {
        humanScore = score
    }
    
    public func getComputerScore() -> Int {
        return computerScore
    }
    
    public func setComputerScore(to score: Int) {
        computerScore = score
    }
    
    public func getDots() -> [[Dot]] {
        return dots
    }
    
    public func getSquares() -> [[BoardCell]] {
        return squares
    }
    
    public func getAdjacents(of dot: Dot) -> [Dot] {
        var adjacents = [Dot]()
        let x = dot.x
        let y = dot.y
        
        if x - 1 >= 0 {
            adjacents.append(dots[x - 1][y])
        }
        if x + 1 < size {
            adjacents.append(dots[x + 1][y])
        }
        if y + 1 < size {
            adjacents.append(dots[x][y + 1])
        }
        if y - 1 >= 0 {
            adjacents.append(dots[x][y - 1])
        }
        return adjacents
    }
    
    public func checkForSquares(from dot: Dot, and otherDot: Dot) {
        // First determine the one or two squares that are adjacent to the move.
        let startSquares: [BoardCell]
        
        // First determine if the line is horizontal or vertical
        if dot.x == otherDot.x {
            // If horizontal, check if we are on the boundary
            if dot.x == 0 {
                // Top boundary, look down
                let square = squares[dot.x][min(dot.y, otherDot.y)]
                square.top = true
                startSquares = [ square ]
            } else if dot.x == size - 1 {
                // Bottom boundary, look up
                let square = squares[dot.x - 1][min(dot.y, otherDot.y)]
                square.bottom = true
                startSquares = [ square ]
            } else {
                // Look up and down
                let squareOne = squares[dot.x][min(dot.y, otherDot.y)]
                squareOne.top = true
                let squareTwo = squares[dot.x - 1][min(dot.y, otherDot.y)]
                squareTwo.bottom = true
                startSquares = [ squareOne, squareTwo ]
            }
        } else {
            // If vertical, check if the y value is == 0
            if dot.y == 0 {
                // Left boundary, look right
                let square = squares[min(dot.x, otherDot.x)][dot.y]
                square.left = true
                startSquares = [ square ]
            } else if dot.y == size - 1 {
                // Right boundary, look left
                let square = squares[min(dot.x, otherDot.x)][dot.y - 1]
                square.right = true
                startSquares = [ square ]
            } else {
                // Look right and left
                let squareOne = squares[min(dot.x, otherDot.x)][dot.y]
                squareOne.left = true
                let squareTwo = squares[min(dot.x, otherDot.x)][dot.y - 1]
                squareTwo.right = true
                startSquares = [ squareOne, squareTwo ]
            }
        }
        // Now that we've determined our start squares to search for fills, let's go!
        for square in startSquares {
            fillSquare(at: square)
        }
        
    }
    
    private func fillSquare(at square: BoardCell) {
        if square.top && square.right && square.bottom && square.left {
            if isComputerTurn {
                computerScore += square.score
            } else {
                humanScore += square.score
            }
        }
    }
}
