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
        if dot.getAdjacents().contains(otherDot) {
            return true
        } else {
            return false
        }
    }
    
    public func checkForSquares(from dot: Dot, and otherDot: Dot) {
        
    }
}
