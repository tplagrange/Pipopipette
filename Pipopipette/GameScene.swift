//
//  GameScene.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/2/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import SpriteKit
import GameplayKit

// Representation of the game scene GUI
class GameScene: SKScene {
    
    // Structure containing the arguments passed by the user at the main menu.
    struct gameParamaterStruct {
        let dotsPerSide: Int
        let ply: Int
    }
    
    private var gameParamaters: gameParamaterStruct? // The parameters for this game
    
    private var background = SKSpriteNode(imageNamed: "paper") // Set the packground to the paper texture
    private var board: Board?  // The board the player interacts with, known as the 'original' board
    private var dots: [[Dot]]? // The dots on the screen
    private var dotSelected: Dot? // The dot the player currently has selected, or nil if he doesn't
    private var isDotSelected: Bool?     // Does the user have a dot selected?
    private var scoreLabel: SKLabelNode? // The Human: AI: score text at the top-left of the window
    private var squares: [[BoardCell]]?  // The squares enclosed by the dots on this board
    
    /// Procedure called when the main menu transitions to the game board
    ///
    /// - Parameter view: The main menu
    override func didMove(to view: SKView) {
        // Set the paper background
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -100
        addChild(background)
        
        // Instantiate our 2D array of dots and squares
        let dotsPerRow = gameParamaters!.dotsPerSide
        let squaresPerRow = dotsPerRow - 1
        self.squares = [[BoardCell]]()
        self.dots = [[Dot]]()
        
        // Layout the dots on our GUI board and fill the 2D array
        var dotNumber = 0
        for _ in 0..<dotsPerRow {
            var colDots = [Dot]()
            for _ in 0..<dotsPerRow {
                // Based on the dot we are placing and the total number of dots
                // We can assess the position in the screen to place the dot
                // First, assess which row and column this dot is in (rows/cols start at 1)
                let row = CGFloat(1 + (dotNumber / dotsPerRow))
                let col = CGFloat(1 + (dotNumber % dotsPerRow))
                let xPos = size.width * (col / CGFloat(dotsPerRow + 1)) - (size.width / 2)
                let yOffset = CGFloat(dotsPerRow) + 1.0 - row
                let yPos = size.height * (yOffset / CGFloat(dotsPerRow + 1)) - (size.height / 2)
                let dot = Dot(dotNumber, Int(row), Int(col), from: self)
                // Set the parameters for the Dot and put in on the GUI
                dot.name = "dot\(dotNumber)"
                dot.position = CGPoint(x: xPos, y: yPos)
                colDots.append(dot)
                addChild(dot)
                dotNumber += 1
            }
            dots!.append(colDots)
        }
        
        // Prepare the squares enclosed by the dots
        var squareNum = 0
        for _ in 0..<squaresPerRow {
            var colSquares = [BoardCell]()
            for _ in 0..<squaresPerRow {
                // Calculate the four dots that surround a square
                let row = squareNum / squaresPerRow
                let col = squareNum % squaresPerRow
                let topLeftDot     = dots![row][col]
                let topRightDot    = dots![row][col + 1]
                let bottomLeftDot  = dots![row + 1][col]
                let bottomRightDot = dots![row + 1][col + 1]
                // Create a square from the collection of dots
                let newSquare = BoardCell(num: squareNum, borderDots: [topLeftDot, topRightDot, bottomLeftDot, bottomRightDot])
                colSquares.append( newSquare )
                // Add a Label with the squares value
                let squareLabel = SKLabelNode(text: "\(newSquare.score)")
                squareLabel.fontColor = SKColor.black
                squareLabel.fontSize = 50
                squareLabel.fontName = "HelveticaNeue"
                squareLabel.position = CGPoint(x: ((topLeftDot.position.x + topRightDot.position.x) / 2),
                                               y: ((topLeftDot.position.y + bottomLeftDot.position.y) / 2))
                // Put the square's value on the GUI
                addChild(squareLabel)
                
                squareNum += 1
            }
            squares!.append(colSquares)
        }
        
        // Prepare the board
        self.board = Board(size: dotsPerRow, with: dots!, with: squares!)
        board!.setPly(to: gameParamaters!.ply)
        board!.setAsOriginal() // Mark this board as the original board, the one we are playing on
    }
    
    /// Set the values passed on by the main menu
    ///
    /// - Parameters:
    ///   - dotsPerSide: The size of the board represented as the number of dots per side
    ///   - ply: The depth at which to run the minimax algorithm
    public func setParamaters(to dotsPerSide: Int, and ply: Int) {
        gameParamaters = gameParamaterStruct(dotsPerSide: dotsPerSide, ply: ply)
    }
    
    // Helper function to return the board held on this game scene
    public func getBoard() -> Board? {
        return board
    }
    
    // Update the text on the GUI showing the score of the AI and the human
    public func updateScores() {
        // Check the board has been generated
        if let originalBoard = board {
            // Get the scores
            let humanScore = originalBoard.getHumanScore()
            let computerScore = originalBoard.getComputerScore()
            // Update the label with the new score
            if let label = scoreLabel {
                label.text = "Human: \(humanScore)    AI: \(computerScore)"
            } else {
                // Label doesn't exist yet, create it
                let label = SKLabelNode(text: "Human: \(humanScore)    AI: \(computerScore)")
                label.fontColor = SKColor.black
                label.fontSize = 60
                label.position = CGPoint(x: 0, y: 0.4 * size.height)
                label.zPosition = 100
                label.fontName = "HelveticaNeue-Bold"
                addChild(label)
                scoreLabel = label
            }
        }
    }
    
    /// Method called when a a touch is made on the game scene
    ///
    /// - Parameter pos: The position of the touch in the window
    func touchDown(atPoint pos : CGPoint) {
        let touchedNodes = nodes(at: pos)
        for touchedNode in touchedNodes {
            // Determine if we're touching a node
            if let dot = touchedNode as? Dot {
                // Player has selected a node
                isDotSelected = true
                dotSelected = dot
                // Animate the node expanding and contracting after touch
                dot.run(SKAction.scale(to: 3.0, duration: 0.5), completion: {
                    dot.run(SKAction.scale(to: 1.0, duration: 0.5))
                })
            }
        }
    }
    
    /// Method called when a touch is lifted off the game scene
    ///
    /// - Parameter pos: The position at which the touch was lifted
    func touchUp(atPoint pos : CGPoint) {
        let touchedNodes = nodes(at: pos)
        for touchedNode in touchedNodes {
            // If the user has selected a dot already...
            if isDotSelected != nil && isDotSelected! {
                // And the user lifted the touch at another dot
                if let dot = touchedNode as? Dot {
                    if dotSelected!.hasConnection(with: dot) {
                        // No action if the two dots are already connected
                        break
                    }
                    // Initiate a human move based on the two dots connected by the player
                    if board!.areAdjacent(this: dot, that: dotSelected!) {
                        board!.initiateHumanMove(with: dot, and: dotSelected!)
                    }
                }
            }
        }
        // Now that our fingers have lifted, no dot is selected anymore
        isDotSelected = false
        dotSelected = nil
    }
    
    // Function that wraps that touch event with a mouse click
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    // Function that wraps a mouse click release with a touch lift
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    // Function called before rendering every frame
    override func update(_ currentTime: TimeInterval) {
        // Always keep the score live!
        updateScores()
    }
}
