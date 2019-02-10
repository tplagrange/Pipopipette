//
//  BoardCell.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/3/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation
import SpriteKit

public class BoardCell: SKSpriteNode {
    
    private let borderDots: [Dot]
    
    public let num: Int
    public var score = Int.random(in: 1...5)
    
    public var top    = false
    public var right  = false
    public var bottom = false
    public var left   = false
    
    init(num: Int, borderDots: [Dot]) {
        self.borderDots = borderDots
        self.num = num
        let texture = SKTexture(imageNamed: "red_square")
        super.init(texture: texture, color: SKColor.clear , size: CGSize(width: 32, height: 32) )
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getBorderDots() -> [Dot] {
        return borderDots
    }
    
    public func copy() -> BoardCell {
        var copyBorderDots = [Dot]()
        for dot in borderDots {
            copyBorderDots.append(dot.copy())
        }
        let square = BoardCell(num: num, borderDots: copyBorderDots)
        square.top = top
        square.right = right
        square.bottom = bottom
        square.left = left
        square.score = score
        return square
    }
    
}
