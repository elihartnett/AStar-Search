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
    @Published var boardSize = 10
    
    @Published var start: BoardSpace?
    @Published var goal: BoardSpace?
    
    var queue: [BoardSpace] = []
    var currentSpace: BoardSpace?
    
    @Published var shortestPath: [BoardSpace] = []
    var visitedSpaces: [BoardSpace] = []
    var distanceTraveled = 0.0
    
    func createBoard() {
        let newBoard = Board(rows: [])
        for row in 0..<boardSize {
            let newRow = BoardRow(spaces: [])
            for col in 0..<boardSize {
                newRow.spaces.append(BoardSpace(type: .empty, gridPoint: GridPoint(x: col, y: boardSize - 1 - row)))
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
    
    func getBoardSpace(at gridPoint: GridPoint) -> BoardSpace {
        return board.rows[Int(boardSize - 1 - gridPoint.y)].spaces[gridPoint.x]
    }
    
    func getAvailableSpaces(space: BoardSpace) -> [BoardSpace] {
        var availableSpaces: [BoardSpace] = []
        
        let xRange = 0...boardSize - 1
        let yRange = 0...boardSize - 1
        
        let x = space.gridPoint.x
        let y = space.gridPoint.y
        
        let moveUp = GridPoint(x: x, y: y + 1)
        let moveDown = GridPoint(x: x, y: y - 1)
        let moveLeft = GridPoint(x: x - 1, y: y)
        let moveRight = GridPoint(x: x + 1, y: y)
        
        if yRange.contains(Int(moveUp.y)) && getBoardSpace(at: moveUp).type != .obstacle {
            availableSpaces.append(getBoardSpace(at: moveUp))
        }
        if yRange.contains(Int(moveDown.y)) && getBoardSpace(at: moveDown).type != .obstacle {
            availableSpaces.append(getBoardSpace(at: moveDown))
        }
        if xRange.contains(Int(moveLeft.x)) && getBoardSpace(at: moveLeft).type != .obstacle {
            availableSpaces.append(getBoardSpace(at: moveLeft))
        }
        if xRange.contains(Int(moveRight.x)) && getBoardSpace(at: moveRight).type != .obstacle {
            availableSpaces.append(getBoardSpace(at: moveRight))
        }
        
        return availableSpaces
    }
    
    func getEuclideanDistanceToGoal(space: BoardSpace) -> Double {
        let a = abs(goal!.gridPoint.x - space.gridPoint.x)
        let b = abs(goal!.gridPoint.y - space.gridPoint.y)
        return sqrt(Double((a*a) + (b*b)))
    }
}
