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
            currentSpace = start
            
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
    
    func getAvailableSpaces() -> [BoardSpace] {
        var availableSpaces: [BoardSpace] = []
        
        let xRange = 0...boardSize - 1
        let yRange = 0...boardSize - 1
        
        let x = currentSpace!.gridPoint.x
        let y = currentSpace!.gridPoint.y
        
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
    
    func goToNextSpace() {
        // Figure out which direction it can move
        let availableSpaces = getAvailableSpaces()
        // Figure out which move is closest to goal
        for space in availableSpaces {
            if space.distanceFromGoal == nil {
                space.distanceFromGoal = getEuclideanDistanceToGoal(space: space)
            }
        }
        // Add to queue of moves with shortest move to goal on top
        queue.append(contentsOf: availableSpaces)
        queue = queue.sorted { lhs, rhs in
            return lhs.distanceFromGoal! > rhs.distanceFromGoal!
        }
        // Pop off shortest move to goal
        let nextSpace = queue.popLast()
        
        // Make move
        currentSpace = nextSpace
        visitedSpaces.append(nextSpace!)
        distanceTraveled += 1
    }
}
