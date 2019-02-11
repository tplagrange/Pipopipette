//
//  Dot.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/3/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//
import Foundation
import SpriteKit

/// A representation of a dot on our pipopipette board
public class Dot: SKSpriteNode {
    public let num: Int // The number of this dot on the board numbered from 0 and up in reading direction
    public let x: Int   // The x-coordinate of this dot in the board's dot array
    public let y: Int   // The respective y-coordinate
    private var connections = [Dot]() // The connections this dot has
    private let gameScene: GameScene  // The GameScene on which to render this dot
    
    init(_ num: Int, _ row: Int, _ col: Int, from gameScene: GameScene) {
        self.num = num
        self.x = row - 1 // row is from the GUI, so ordering starts at 1
        self.y = col - 1 // Same with col; but x and y need to be indeces
        self.gameScene = gameScene
        let texture = SKTexture(imageNamed: "dot") // Sprite Kit image to represent the dot visually
        super.init(texture: texture, color: SKColor.clear , size: CGSize(width: 32, height: 32) ) // Required super call to implement SKSpriteNode
    }
    
    /// Required initializer to implement SKSpriteNode
    ///
    /// - Parameter aDecoder: The decoder supplied to the SKSpriteNode object at creation
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Return a exclusive copy of this dot for use in node generation during minimax
    ///
    /// - Returns: Identical copy of this dot at a different memory address
    public func copy() -> Dot {
        let copyDot = Dot(num, x + 1, y + 1, from: gameScene)
        copyDot.setConnections(as: connections)
        return copyDot
    }
    
    /// Helper function for use when copying a board to simply set a dots connections from it's original's
    ///
    /// - Parameter newConnections: Array of dot connections to replace a blank set
    public func setConnections(as newConnections: [Dot]) {
        connections = newConnections
    }
    
    /// Procedure for connecting two dots on a board
    ///
    /// - Parameters:
    ///   - otherDot: The dot this dot will connect to
    ///   - computerPlayer: Boolean that's true if the computer made this move
    ///   - originalBoard: Boolean that's true if this is happening on the real board, not one generated during minimax
    public func connect(to otherDot: Dot, as computerPlayer: Bool, from originalBoard: Bool) {
        // Disallow connections that already exist.
        if self.hasConnection(with: otherDot) {
            return
        }
        
        // If this is on the original board, we should render the connection between the dots as a line
        if originalBoard {
            // Render the line
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: self.position)
            path.addLine(to: otherDot.position)
            line.path = path
            // Change color depending on who made the move
            if computerPlayer {
                line.strokeColor = SKColor.white
            } else {
                line.strokeColor = SKColor.red
            }
            line.lineWidth = 5
            
            gameScene.addChild(line)
        }
        
        // Add the other dot to this dots array of connections
        connections.append(otherDot)
        // Do the same for the other dot
        otherDot.registerConnection(with: self)
    }
    
    // Helper function so that if this dot is connected to, it recognizes the connection
    public func registerConnection(with otherDot: Dot) {
        connections.append(otherDot)
    }
    
    /// Helper function for checking if two dots are connected
    ///
    /// - Parameter otherDot: Dot to check if we're connected to
    /// - Returns: True if there is a connection between this dot and the other dot
    public func hasConnection(with otherDot: Dot) -> Bool {
        for connection in connections {
            if connection.x == otherDot.x && connection.y == otherDot.y {
                return true
            }
        }
        return false
    }
    
}
