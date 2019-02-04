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
    private let size: Int
    private let numDots: Int
    private let dots: [SKSpriteNode]
    private let squares: [BoardCell]
    private let gameScene: GameScene
    
    init(size: Int, with dots: [Dot], with squares: [BoardCell], from gameScene: GameScene) {
        self.size = size
        self.numDots = size * size
        self.dots = dots
        self.squares = squares
        self.gameScene = gameScene
    }
    
    public func areAdjacent(this dot: Dot, that otherDot: Dot) -> Bool {
        if getAdjacents(for: dot).contains(otherDot) {
            return true
        } else {
            return false
        }
    }
    
    public func getAdjacents(for dot: Dot) -> [Dot] {
        var adjacents = [Dot]()
        
        for num in [dot.num + 1, dot.num - 1, dot.num + size, dot.num - size] {
            gameScene.enumerateChildNodes(withName: "dot\(num)") {
                (node, stop) in
                
                if let adjacentDot = node as? Dot {
                    adjacents.append(adjacentDot)
                } else {
                    print("Error @ getAdjacents casting adjacentDot to Dot")
                }
            }
        }
        
        return adjacents
    }
    
    public func checkForSquares(from dot: Dot) {
        
    }
}
