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
    
    private var label: SKLabelNode?
    private var spinnyNode: SKShapeNode?
    private var board: Board?
    private var squares: [BoardCell]?
    private var dots: [Dot]?
    private var isDotSelected: Bool?
    private var dotSelected: Dot?
    private var maxDistance: CGFloat?
    
    override func didMove(to view: SKView) {
        
        // Number of dots on the board
        let side = 5
        let numDots = side * side
        self.squares = [BoardCell]()
        self.dots = [Dot]()
        
        // Layout the dots on our board
        for dotNumber in 0..<numDots {
            let dot = Dot(dotNumber, from: self)
            dot.name = "dot\(dotNumber)"
            // Based on the dot we are placing and the total number of dots
            // We can assess the position in the screen to place the dot
            // First, assess which row and column this dot is in (index starts at 1)
            let row = CGFloat(1 + (dotNumber / side))
            let col = CGFloat(1 + (dotNumber % side))
            let xPos = size.width * (col / CGFloat(side + 1)) - (size.width / 2)
            let yOffset = CGFloat(side) + 1.0 - row
            let yPos = size.height * (yOffset / CGFloat(side + 1)) - (size.height / 2)
            dot.position = CGPoint(x: xPos, y: yPos)
            dots!.append(dot)
            addChild(dot)
        }
        
        // Prepare the squares enclosed by the dots
        for dotNumber in 0..<numDots {
            if dotNumber + 1 + side >= numDots {
                break
            }
            var borderDots = [Dot]()
            borderDots.append( childNode(withName: "dot\(dotNumber)")! as! Dot)
            borderDots.append( childNode(withName: "dot\(dotNumber + 1)")! as! Dot)
            borderDots.append( childNode(withName: "dot\(dotNumber + side)")! as! Dot)
            borderDots.append( childNode(withName: "dot\(dotNumber + 1 + side)")! as! Dot)
            squares!.append( BoardCell(borderDots: borderDots) )
        }
        
        // Prepare the board
        self.board = Board(size: side, with: dots!, with: squares!, from: self)
        /// Below is all from the default xcode game template
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
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
                    if board!.areAdjacent(this: dot, that: dotSelected!) {
                        dot.connect(to: dotSelected!)
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
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
