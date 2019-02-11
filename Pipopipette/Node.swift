//
//  Node.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/9/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation

/// Representation of a node for use with the minimax algorithm
public class Node {
    private var type: nodeType   // MIN or MAX?
    private var board: Board     // The representation of the board at this node
    private var parent: Node?    // The parent node, or nil if this is root
    private var children: [Node] // The children of this node
    
    public var score = 0         // Score is only changed during evaluation
    
    init(is type: nodeType, parent parentNode: Node?, with board: Board) {
        self.type = type
        self.board = board
        self.parent = parentNode
        self.children = [Node]()
    }
    
    /// Return the board representation held by this node
    public func getBoard() -> Board {
        return board
    }
    
    /// Return the type of this node
    public func getType() -> nodeType {
        return type
    }
    
    /// Return this node's children
    public func getChildren() -> [Node] {
        return children
    }
    
    /// Add a child to this node
    public func addChild(child node: Node) {
        children.append(node)
    }
    
    /// Method for determining if this node is a leaf node
    ///
    /// - Returns: True if this node is a leaf
    public func isLeaf() -> Bool {
        // Leaves have no children
        return children.count == 0
    }
}
