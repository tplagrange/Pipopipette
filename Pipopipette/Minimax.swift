//
//  Minimax.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/9/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation

/// Main loop for running the minimax algrotihm from the current state of the game
///
/// - Parameters:
///   - currentBoard: The board after a human made a move.
///   - ply: The depth at which to generate nodes for the problem tree
public func minimax(on currentBoard: Board, to ply: Int) {
    
    // Create start node as MAX node with current board configuration
    let startnode = Node(is: nodeType.MAX, parent: nil, with: currentBoard.copy())

    // Expand nodes down to ply
    DispatchQueue.global(qos: .userInitiated).sync {
        generateNodes(from: startnode, to: ply)
    }
    
    // Call recursive function to determine the score at root
    let maxScore = backUpValues(from: startnode)
    
    // AI chooses the move associated with the child-node whose back-ed up value determined the value at the root
    if let boardChoice = startnode.getChildren().first(where: {$0.score == maxScore}) {
        // Determine which dots were connected to make the move
        let(dotOne, dotTwo) = boardChoice.getBoard().getLastMove()
        let currentDots = currentBoard.getDots()
        // Make the move on the original board
        currentBoard.initiateComputerMove(with: currentDots[dotOne.x][dotOne.y], and: currentDots[dotTwo.x][dotTwo.y])
    } else {
        print("[ERROR]: Root node produced no children.")
    }
}

/// Simple enum to represent the possible node types produced by minimax
public enum nodeType {
    case MIN
    case MAX
}

/// Procedure to recursively back up values from nodes to root
///
/// - Parameter node: Node from which to begin recursive backing up
/// - Returns: The selected score for the node at this level
private func backUpValues(from node: Node) -> Int {
    if (node.isLeaf()) {
        node.score = eval(at: node)
        return node.score
    } else {
        var scores = [Int]()
        for child in node.getChildren() {
            let score = backUpValues(from: child)
            scores.append(score)
        }
        switch node.getType() {
        case .MAX:
            node.score = scores.max()!
            return node.score
        case .MIN:
            node.score = scores.min()!
            return node.score
        }
    }
}

/// Evaluation function to detmine the score of a generated node
///
/// - Parameter node: Node at which to evaluate a score
/// - Returns: The score for the node as an Integer.
private func eval(at node: Node) -> Int {
    return node.getBoard().getComputerScore() - node.getBoard().getHumanScore()
}

/// Recursively generate nodes for our tree down to the given ply
///
/// - Parameters:
///   - node: Node at which to start recursive node generation
///   - ply: Counter variable that signifies we've hit the ply when equal to zero
private func generateNodes(from node: Node, to ply: Int ) {

    // Counter for ply has hit zero, we will not generate nodes from this point down.
    if ply <= 0 {
        return
    }
    
    // We are at the oppposite level of the parent node.
    let nodeLevel : nodeType
    if node.getType() == .MAX {
        nodeLevel = .MIN
    } else {
        nodeLevel = .MAX
    }
    
    // Store the parent node's board state
    let board = node.getBoard()
    
    // For each Dot, there are 0 to 4 possible moves
    // For each of those moves, a new board can be generated
    // A node will be generated with the board
    let dots = board.getDots()
    let dotsPerSide = board.size

    // For each dot on the board, generate new boards from 0 to 4 legal moves
    for dotNumber in 0..<(dotsPerSide * dotsPerSide) {
        let row = dotNumber / dotsPerSide
        let col = dotNumber % dotsPerSide
        
        // Determine which dot in the 2D array we are working with
        let dot = dots[row][col]
        
        // Multi-threading function.
        let generateNodesGroup = DispatchGroup()
        
        // Each dot will connect to an adjacent dot and generate a state from that move
        for adjacent in board.getAdjacents(of: dot) {
            // No new state will be generated if the connection already exists.
            if dot.hasConnection(with: adjacent) {
                continue
            } else {
                // Multi-threading function
                generateNodesGroup.enter()
                
                // Make a unique copy of this dot's board
                let newBoard = board.copy()
                let newDots = newBoard.getDots()
                
                // MIN nodes simulate computer moves, MAX nodes simulate human moves
                if nodeLevel == .MIN {
                    newBoard.initiateComputerMove(with: newDots[dot.x][dot.y], and: newDots[adjacent.x][adjacent.y])
                } else {
                    newBoard.simulateHumanMove(with: newDots[dot.x][dot.y], and: newDots[adjacent.x][adjacent.y])
                }
                
                // Recurse down from this newly generated node until we hit the ply.
                let newNode = Node(is: nodeLevel, parent: node, with: newBoard)
                node.addChild(child: newNode)
                generateNodes(from: newNode, to: (ply - 1) )
                
                // Multi-threading function
                generateNodesGroup.leave()
            }
        }
        
        // Multi-threading function
        generateNodesGroup.wait()
    }
    // Each legal move for each child for the node passed to this function has been generated.
    return
}
