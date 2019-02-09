//
//  Dot.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/3/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//
import Foundation
import SpriteKit

public class Dot: SKSpriteNode {
    public let num: Int
    private var connections = [Dot]()
    private var adjacents = [Dot]()
    private let gameScene: GameScene
    
    init(_ num: Int, from gameScene: GameScene) {
        self.num = num
        self.gameScene = gameScene
        let texture = SKTexture(imageNamed: "dot")
        super.init(texture: texture, color: SKColor.clear , size: CGSize(width: 32, height: 32) )
        setAdjacents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func connect(to otherDot: Dot) {
        if connections.contains(otherDot) {
            // Alert that the move is not valid?
            return
        }
        
        // Render the line
        let line = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: self.position)
        path.addLine(to: otherDot.position)
        line.path = path
        line.strokeColor = SKColor.red
        line.lineWidth = 5
        
        connections.append(otherDot)
        otherDot.registerConnection(with: self)
        
        gameScene.addChild(line)
    }
    
    public func registerConnection(with otherDot: Dot) {
        connections.append(otherDot)
    }
    
    public func hasConnection(with otherDot: Dot) -> Bool {
        return connections.contains(otherDot)
    }
    
    /// Getters ///
    public func getAdjacents() -> [Dot] {
        return adjacents
    }
    
    // There must be a better way to do these four functions...
    public func up() -> Dot? {
        if let board = gameScene.getBoard() {
            if let dot = gameScene.childNode(withName: "dot\(num - board.size)") {
                return (dot as! Dot)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func down() -> Dot? {
        if let board = gameScene.getBoard() {
            if let dot = gameScene.childNode(withName: "dot\(num + board.size)") {
                return (dot as! Dot)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func right() -> Dot? {
        if let board = gameScene.getBoard() {
            if let dot = gameScene.childNode(withName: "dot\(num + 1)") {
                if (num + 1) % board.size < num % board.size {
                    return nil
                } else {
                    return (dot as! Dot)
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func left() -> Dot? {
        if let board = gameScene.getBoard() {
            if let dot = gameScene.childNode(withName: "dot\(num - 1)") {
                if (num - 1) % board.size > num % board.size {
                    return nil
                } else {
                    return (dot as! Dot)
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func setAdjacents() {
        for node in [ up(), right(), down(), left()] {
            if node == nil {
                continue
            } else {
                adjacents.append(node!)
            }
        }
    }
    
}
