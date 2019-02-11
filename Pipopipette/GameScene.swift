//
//  GameScene.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/2/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    struct gameParamaterStruct {
        let dotsPerSide: Int
        let ply: Int
    }
    
    private var gameParamaters: gameParamaterStruct?
    
    private var scoreLabel: SKLabelNode?
    private var background = SKSpriteNode(imageNamed: "paper")
    private var board: Board?
    private var squares: [[BoardCell]]?
    private var dots: [[Dot]]?
    private var isDotSelected: Bool?
    private var dotSelected: Dot?
    
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -100
        addChild(background)
        
        // Number of dots on the board
        let dotsPerRow = gameParamaters!.dotsPerSide
        let squaresPerRow = dotsPerRow - 1
        self.squares = [[BoardCell]]()
        self.dots = [[Dot]]()
        
        // Layout the dots on our GUI board
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
                squareLabel.position = CGPoint(x: ((topLeftDot.position.x + topRightDot.position.x) / 2), y: ((topLeftDot.position.y + bottomLeftDot.position.y) / 2))
                addChild(squareLabel)
                
                squareNum += 1
            }
            squares!.append(colSquares)
        }
        
        // Prepare the board
        self.board = Board(size: dotsPerRow, with: dots!, with: squares!)
        board!.setPly(to: gameParamaters!.ply)
        board!.setAsOriginal()
    }
    
    public func setParamaters(to dotsPerSide: Int, and ply: Int) {
        gameParamaters = gameParamaterStruct(dotsPerSide: dotsPerSide, ply: ply)
    }
    
    public func getBoard() -> Board? {
        return board
    }
    
    public func updateScores() {
        if let originalBoard = board {
            let humanScore = originalBoard.getHumanScore()
            let computerScore = originalBoard.getComputerScore()
            if let label = scoreLabel {
                label.text = "Human: \(humanScore)    AI: \(computerScore)"
            } else {
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
    
    public func updateSquares() {
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let touchedNodes = nodes(at: pos)
        for touchedNode in touchedNodes {
            if let dot = touchedNode as? Dot {
                print(pos)
                isDotSelected = true
                dotSelected = dot
                dot.run(SKAction.scale(to: 3.0, duration: 0.5), completion: {
                    dot.run(SKAction.scale(to: 1.0, duration: 0.5))
                })
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let touchedNodes = nodes(at: pos)
        for touchedNode in touchedNodes {
            if isDotSelected != nil && isDotSelected! {
                if let dot = touchedNode as? Dot {
                    if dotSelected!.hasConnection(with: dot) {
                        break
                    }
                    if board!.areAdjacent(this: dot, that: dotSelected!) {
                        board!.initiateHumanMove(with: dot, and: dotSelected!)
                    }
                }
            }
        }
        isDotSelected = false
        dotSelected = nil
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        updateScores()
    }
}
