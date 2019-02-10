//
//  Node.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/9/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation

public class Node {
    private var type: nodeType
    private var board: Board
    private var parent: Node?
    private var children: [Node]
    
    public var score = 0
    
    init(is type: nodeType, parent parentNode: Node?, with board: Board) {
        self.type = type
        self.board = board
        self.parent = parentNode
        self.children = [Node]()
    }
    
    public func getBoard() -> Board {
        return board
    }
    
    public func getType() -> nodeType {
        return type
    }
    
    public func getChildren() -> [Node] {
        return children
    }
    
    public func addChild(child node: Node) {
        children.append(node)
    }
    
    public func isLeaf() -> Bool {
        return children.count == 0
    }
}
