//
//  Board.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/3/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation
import SpriteKit

/// Representation of the pipopipette board and functions to interact with the dots and squares within it
public class Board {
    public let size: Int // The size of this board, or the number of dots per side
    
    private let dots: [[Dot]]   // The dots on this board as a 2D array
    private let numDots: Int    // The number of dots on the board
    private let numSquares: Int // The number of squares on the board
    private let squares: [[BoardCell]]  // The squares on this board as a 2D array
    private var computerScore: Int      // The computer's score on this board
    private var humanScore: Int         // The human's score on this board
    private var isComputerTurn = false  // True if it's the computer's turn to make a move
    private var lastMove: (Dot, Dot)?   // The two dots that were connected on the last move made
    private var original: Bool          // True iff this is the board from the interactive GUI
    private var ply = 0                 // The depth at which to search, is changed by the main menu
    
    init(size: Int, with dots: [[Dot]], with squares: [[BoardCell]]) {
        self.size = size
        self.numDots = size * size
        self.numSquares = (size - 1) * (size - 1)
        self.dots = dots
        self.squares = squares
        self.humanScore = 0
        self.computerScore = 0
        original = false // Only the gamescene can affect the original board to mark it as original
    }
    
    /// Helper function used by the GUI to set the ply that this board will be expanded down to
    ///
    /// - Parameter ply: The horizon, point at which to stop generating nodes during minimax
    public func setPly(to ply: Int) {
        self.ply = ply
    }
 
    /// Procedure to handle a move made by the player
    ///
    /// - Parameters:
    ///   - dot: The first dot the user selected
    ///   - otherDot: The dot the user wanted to form a connection with
    public func initiateHumanMove(with dot: Dot, and otherDot: Dot) {
        // Don't register the user's move if it's not his turn!
        if isComputerTurn {
            return
        }
        
        // Register a connection between the two dots
        dot.connect(to: otherDot, as: isComputerTurn, from: original)
        // Update the above as the last move made on this board
        updateLastMove(with: dot, and: otherDot)
        // Check if the last move filled any squares
        checkForSquares(from: dot, and: otherDot)
        // Turn is over, hand over control to the computer
        isComputerTurn = true
        // Run the computer's turn on a different thread to avoiding blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async { [ weak self] in
            guard let self = self else {
                return
            }
            // Start the computers turn!
            self.startComputerTurn()
        }
    }

    private func startComputerTurn() {
        print("Starting Computer Turn")
        minimax(on: self, to: ply)
        isComputerTurn = false
    }
    
    /// Simulates a move made by the player for use during minimax
    ///
    /// - Parameters:
    ///   - dot: First dot in the connection
    ///   - otherDot: The second dot in the connection
    public func simulateHumanMove(with dot: Dot, and otherDot: Dot) {
        // Act like it's the human's turn
        isComputerTurn = false
        // Register a connection
        dot.connect(to: otherDot, as: isComputerTurn, from: false)
        // Update the last move
        updateLastMove(with: dot, and: otherDot)
        // Check for square fills
        checkForSquares(from: dot, and: otherDot)
        // Hand over control back to the computer ;)
        isComputerTurn = true
    }
    
    /// Simulates a move made by the computer for use during minimax
    ///
    /// - Parameters:
    ///   - dot: The first dot in the conneciton
    ///   - otherDot: The second dot.
    public func initiateComputerMove(with dot: Dot, and otherDot: Dot) {
        // Enforce that it is the computer's turn
        isComputerTurn = true
        // Register a connection
        dot.connect(to: otherDot, as: isComputerTurn, from: original)
        // Update the last move
        updateLastMove(with: dot, and: otherDot)
        // Check for square fills
        checkForSquares(from: dot, and: otherDot)
        // Hand over control back to the filthy human
        isComputerTurn = false
    }
    
    // Setter function called by the GUI to mark this board as the original board, the real deal!
    public func setAsOriginal() {
        original = true
    }
    
    // Helper function to update which move was last made on the board
    public func updateLastMove(with dot: Dot, and otherDot: Dot) {
        lastMove = (dot, otherDot)
    }
    
    // Helper function to retrive the last move made on the baord
    public func getLastMove() -> (Dot, Dot) {
        return lastMove!
    }
    
    // Helper funciton to determine if two dots on the board are adjacent
    public func areAdjacent(this dot: Dot, that otherDot: Dot) -> Bool {
        if getAdjacents(of: dot).contains(otherDot) {
            return true
        } else {
            return false
        }
    }
    
    // Getter for the human's score on this board
    public func getHumanScore() -> Int {
        return humanScore
    }
    
    // Setter for the human's score on this board (called by fillSquares() )
    public func setHumanScore(to score: Int) {
        humanScore = score
    }
    
    // Getter for the computer's score on this board
    public func getComputerScore() -> Int {
        return computerScore
    }
    
    // Setter for the computer's score on this board (called by fillSquares() )
    public func setComputerScore(to score: Int) {
        computerScore = score
    }
    
    // Getter for the 2D array of the dots on this board
    public func getDots() -> [[Dot]] {
        return dots
    }

    // Getter for the 2D array of the squares on this board
    public func getSquares() -> [[BoardCell]] {
        return squares
    }
    
    /// Procedure for determining the dots adjacent to another dot
    ///
    /// - Parameter dot: Dot of which to find adjacent dots
    /// - Returns: Array containing 2 to 4 dots that are adjacent to 'dot'
    public func getAdjacents(of dot: Dot) -> [Dot] {
        var adjacents = [Dot]()
        let x = dot.x
        let y = dot.y
        
        // Check if going up, right, down, or left (respectively) is legal
        if x - 1 >= 0 {
            // If it's legal, append it to the array of adjacents for this dot
            adjacents.append(dots[x - 1][y])
        }
        if y + 1 < size {
            adjacents.append(dots[x][y + 1])
        }
        if x + 1 < size {
            adjacents.append(dots[x + 1][y])
        }
        if y - 1 >= 0 {
            adjacents.append(dots[x][y - 1])
        }
        return adjacents
    }
    
    /// Check if a square has been filled in by the last move
    ///
    /// - Parameters:
    ///   - dot: First dot from the last move
    ///   - otherDot: Second dot
    public func checkForSquares(from dot: Dot, and otherDot: Dot) {
        let startSquares: [BoardCell] // Will hold the one or two square(s) adjacent to the move made
        
        // As a small optimization, we only check if the squares adjacent to the move were filled instead of looking all over
        
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
    
    /// Helper function to return a copy of this board for use with node generation during minimax.
    ///
    /// - Returns: An exclusive copy of this board at a different memory address.
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
}
