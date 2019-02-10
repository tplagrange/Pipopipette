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
    public let x: Int
    public let y: Int
    private var connections = [Dot]()
    private let gameScene: GameScene
    
    init(_ num: Int, _ row: Int, _ col: Int, from gameScene: GameScene) {
        self.num = num
        self.x = row - 1
        self.y = col - 1
        self.gameScene = gameScene
        let texture = SKTexture(imageNamed: "dot")
        super.init(texture: texture, color: SKColor.clear , size: CGSize(width: 32, height: 32) )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func copy() -> Dot {
        let copyDot = Dot(num, x + 1, y + 1, from: gameScene)
        copyDot.setConnections(as: connections)
        return copyDot
    }
    
    public func setConnections(as newConnections: [Dot]) {
        connections = newConnections
    }
    
    public func connect(to otherDot: Dot, as computerPlayer: Bool, from originalBoard: Bool) {
        if self.hasConnection(with: otherDot) {
            print("returning from connect")
            return
        }
        
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
        
        connections.append(otherDot)
        otherDot.registerConnection(with: self)
    }
    
    public func registerConnection(with otherDot: Dot) {
        connections.append(otherDot)
    }
    
    public func hasConnection(with otherDot: Dot) -> Bool {
        for connection in connections {
            if connection.x == otherDot.x && connection.y == otherDot.y {
                return true
            }
        }
        return false
    }
    
}
