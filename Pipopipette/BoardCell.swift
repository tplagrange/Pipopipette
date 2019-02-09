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
    private let num: Int
    private var filled = false
    
    init(num: Int, borderDots: [Dot]) {
        self.borderDots = borderDots
        self.num = num
        let texture = SKTexture(imageNamed: "red_square")
        super.init(texture: texture, color: SKColor.clear , size: CGSize(width: 32, height: 32) )
        print("Square #\(num) bordered by:")
        for borderDot in borderDots {
            print(borderDot.num)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getBorderDots() -> [Dot] {
        return borderDots
    }
    
    public func isFilled() -> Bool {
        return filled
    }
    
}
