//
//  Minimax.swift
//  Pipopipette
//
//  Created by Thomas Lagrange on 2/9/19.
//  Copyright © 2019 Thomas Lagrange. All rights reserved.
//

import Foundation

public func minimax(on currentBoard: Board, to ply: Int) {
    // Create start node as MAX node with current board configuration
    let startnode = Node(is: nodeType.MAX, parent: nil, with: currentBoard.copy())

    // Expand my nodes down to ply
    generateNodes(from: startnode, to: ply)
    
    let maxScore = backUpValues(from: startnode)
    
    print(maxScore)
    
    if let boardChoice = startnode.getChildren().first(where: {$0.score == maxScore}) {
        // AI chooses the move associated with the child-node whose back-ed up value determined the value at the root
        let(dotOne, dotTwo) = boardChoice.getBoard().getLastMove()
        print("\(dotOne.num),\(dotTwo.num)")
        let currentDots = currentBoard.getDots()
        currentBoard.initiateComputerMove(with: currentDots[dotOne.x][dotOne.y], and: currentDots[dotTwo.x][dotTwo.y])
        
        return
    } else {
        print("ruh roh")
    }
}

public enum nodeType {
    case MIN
    case MAX
}

// We will traverse the tree down to the leaves and then back up the values all the way to root
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

private func eval(at node: Node) -> Int {
    return node.getBoard().getComputerScore() - node.getBoard().getHumanScore()
}

private func generateNodes(from node: Node, to ply: Int ) {
    let nodeLevel : nodeType
    if ply <= 0 {
        return
    }
    
    if node.getType() == .MAX {
        nodeLevel = .MIN
    } else {
        nodeLevel = .MAX
    }

    let board = node.getBoard()
    
    // For each Dot, there are 0 to 4 possible moves
    // For each of those moves, a new board can be generated
    // A node will be generated with the board and it's score
    let dots = board.getDots()
    let dotsPerSide = board.size
    // Top level loop will repeat O(n) where n is the number of dots on the board
    for dotNumber in 0..<(dotsPerSide * dotsPerSide) {
        let row = dotNumber / dotsPerSide
        let col = dotNumber % dotsPerSide
        
        let dot = dots[row][col]
        // This loop runs O(n<=4)
        for adjacent in board.getAdjacents(of: dot) {
            if dot.hasConnection(with: adjacent) {
                continue
            } else {
                let newBoard = board.copy()
                let newDots = newBoard.getDots()
                
                if nodeLevel == .MIN {
                    newBoard.initiateComputerMove(with: newDots[dot.x][dot.y], and: newDots[adjacent.x][adjacent.y])
                } else {
                    newBoard.simulateHumanMove(with: newDots[dot.x][dot.y], and: newDots[adjacent.x][adjacent.y])
                }
                let newNode = Node(is: nodeLevel, parent: node, with: newBoard)
                node.addChild(child: newNode)
                
                generateNodes(from: newNode, to: (ply - 1) )
            }
        }
    }
    
    return
}
