//
//  BoardModel.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation
import SwiftUI

class BoardModel: ObservableObject {
    
    @Published var board = Board(rows: [])
    @Published var boardSize = 10.0
    @Published var start: BoardSpace?
    @Published var goal: BoardSpace?
    
    func createBoard() {
        let newBoard = Board(rows: [])
        for row in 0..<Int(boardSize) {
            let newRow = BoardRow(spaces: [])
            for col in 0..<Int(boardSize) {
                newRow.spaces.append(BoardSpace(type: .empty, x: col, y: Int(boardSize) - row - 1))
            }
            newBoard.rows.append(newRow)
        }
        board = newBoard
    }
    
    func handleConfigurationTap(addSpaceType: SpaceType, space: BoardSpace) {
        switch addSpaceType {
        case .start:
            resetStart()
            if space.type == .goal {
                resetGoal()
            }
            space.type = .start
            start = space
            
        case .empty:
            if space.type == .start {
                resetStart()
            }
            else if space.type == .goal {
                resetGoal()
            }
            space.type = .empty
            
        case .obstacle:
            if space.type == .start {
                resetStart()
            }
            space.type = .obstacle
            
        case .goal:
            resetGoal()
            if space.type == .start {
                resetStart()
            }
            space.type = .goal
            goal = space
        }
    }
        
    func resetStart() {
        start?.type = .empty
        start = nil
    }
    
    func resetGoal() {
        goal?.type = .empty
        goal = nil
    }
    
    func getSpaceColor(type: SpaceType) -> Color {
        switch type {
        case .start:
            return .white
        case .empty:
            return .green
        case .obstacle:
            return .red
        case .goal:
            return .black
        }
    }
    
    func getBoardSpace(at point: CGPoint) -> BoardSpace {
        return board.rows[Int(point.y)].spaces[Int(point.x)]
    }
    
    func getAvailableMoves(space: BoardSpace) -> [CGPoint] {
        var moves: [CGPoint] = []
        
        let xRange = 0...boardSize - 1
        let yRange = 0...boardSize - 1
        
        let x = space.x
        let y = space.y
        
        let moveUp = CGPoint(x: x, y: y + 1)
        let moveDown = CGPoint(x: x, y: y - 1)
        let moveLeft = CGPoint(x: x - 1, y: y)
        let moveRight = CGPoint(x: x + 1, y: y)
        
        if yRange.contains(moveUp.y) && getBoardSpace(at: moveUp).type != .obstacle {
            moves.append(moveUp)
        }
        if yRange.contains(moveDown.y) && getBoardSpace(at: moveDown).type != .obstacle {
            moves.append(moveDown)
        }
        if xRange.contains(moveLeft.x) && getBoardSpace(at: moveLeft).type != .obstacle {
            moves.append(moveLeft)
        }
        if xRange.contains(moveRight.x) && getBoardSpace(at: moveRight).type != .obstacle {
            moves.append(moveRight)
        }
        
        return moves
    }
}
