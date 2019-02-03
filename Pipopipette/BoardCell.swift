//
//  BoardCell.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/3/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation
import SpriteKit

public class BoardCell {
    
    private let borderDots: [Dot]
    
    init(borderDots: [Dot]) {
        self.borderDots = borderDots
        
    }
    
    public func getBorderDots() -> [Dot] {
        return borderDots
    }
    
}
