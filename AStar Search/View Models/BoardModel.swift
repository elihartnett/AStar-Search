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
    var boardSize = 10
    let boardSizeIncreaseRate = 2
    
    @Published var start: BoardSpace?
    @Published var goal: BoardSpace?
    
    @Published var open = Array<BoardSpace>()
    @Published var closed = Array<BoardSpace>()
    // Distance from start node
    @Published var g = [String : Int]()
    // Lower bound heuristic on optimal path cost to goal node
    @Published var h = [String : Int]()
    // Optimal cost from start to goal
    @Published var f = [String : Int]()
    @Published var parent = [String : BoardSpace?]()
    
    func createBoard(boardSize: Int) -> Board {
        let newBoard = Board(rows: [])
        for row in 0..<boardSize {
            let newRow = BoardRow(spaces: [])
            for col in 0..<boardSize {
                newRow.spaces.append(BoardSpace(type: .empty, gridPoint: GridPoint(x: col, y: row)))
            }
            newBoard.rows.append(newRow)
        }
        return newBoard
    }
    
    func resetBoard() {
        boardSize = 10
        board = createBoard(boardSize: boardSize)
        
        start = nil
        goal = nil
        
        open = Array<BoardSpace>()
        closed = Array<BoardSpace>()
        g = [String : Int]()
        h = [String : Int]()
        f = [String : Int]()
    }
    
    func scaleBoard() {
        let newBoard = createBoard(boardSize: boardSize * boardSizeIncreaseRate)
        
        if let start {
            let newStartGridPoints = getScaledGridPointsForGridPoint(gridPoint: start.gridPoint)
            start.gridPoint = getSmallestGridPointInGridPoints(gridPoints: newStartGridPoints)
        }
        
        if let goal {
            let newGoalGridpoints = getScaledGridPointsForGridPoint(gridPoint: goal.gridPoint)
            goal.gridPoint = getSmallestGridPointInGridPoints(gridPoints: newGoalGridpoints)
        }
                
        for (rowIndex, row) in board.rows.enumerated() {
            for (colIndex, _) in row.spaces.enumerated() {
                let boardGridPoint = GridPoint(x: colIndex, y: rowIndex)
                let boardSpace = getBoardSpace(at: boardGridPoint)!
                
                let scaledGridPoints = getScaledGridPointsForGridPoint(gridPoint: boardGridPoint)
                for gridPoint in scaledGridPoints {
                    newBoard.rows[gridPoint.y].spaces[gridPoint.x].type = boardSpace.type == .start || boardSpace.type == .goal ? .empty : boardSpace.type
                }
            }
        }
        
        if let start {
            let newBoardSpace = newBoard.rows[start.gridPoint.y].spaces[start.gridPoint.x]
            newBoardSpace.type = .start
        }
        
        if let goal {
            let newBoardSpace = newBoard.rows[goal.gridPoint.y].spaces[goal.gridPoint.x]
            newBoardSpace.type = .goal
        }
        
        board = newBoard
        boardSize *= 2
    }
    
    func getScaledGridPointsForGridPoint(gridPoint: GridPoint) -> [GridPoint] {
        var gridpoints: [GridPoint] = []
        
        let minX = gridPoint.x * boardSizeIncreaseRate
        let minY = gridPoint.y * boardSizeIncreaseRate
        
        let maxX = minX + boardSizeIncreaseRate - 1
        let maxY = minY + boardSizeIncreaseRate - 1
        
        for xSpace in minX...maxX {
            for ySpace in minY...maxY {
                gridpoints.append(GridPoint(x: xSpace, y: ySpace))
            }
        }
        
        return gridpoints
    }
    
    func getSmallestGridPointInGridPoints(gridPoints: [GridPoint]) -> GridPoint {
        var smallest = gridPoints[0]
        for gridPoint in gridPoints {
            if gridPoint.x < smallest.x && gridPoint.y < smallest.y {
                smallest = gridPoint
            }
        }
        return smallest
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
        if let start {
            board.rows[start.gridPoint.y].spaces[start.gridPoint.x].type = .empty
        }
        start = nil
    }
    
    func resetGoal() {
        if let goal {
            board.rows[goal.gridPoint.y].spaces[goal.gridPoint.x].type = .empty
        }
        goal = nil
    }
    
    func boardContainsSpaceAtGridPoint(gridPoint: GridPoint) -> Bool {
        let xRange = 0...boardSize - 1
        let yRange = 0...boardSize - 1
        
        return (xRange.contains(gridPoint.x) && yRange.contains((gridPoint.y)))
    }
    
    func getBoardSpace(at gridPoint: GridPoint) -> BoardSpace? {
        guard boardContainsSpaceAtGridPoint(gridPoint: gridPoint) else { return nil }
        return board.rows[gridPoint.y].spaces[gridPoint.x]
    }
    
    func getAvailableSpacesFromGridPoint(gridPoint: GridPoint) -> [BoardSpace] {
        var availableSpaces: [BoardSpace] = []
        
        let x = gridPoint.x
        let y = gridPoint.y
        
        let possibleMoves = [GridPoint(x: x, y: y + 1), GridPoint(x: x, y: y - 1), GridPoint(x: x - 1, y: y), GridPoint(x: x + 1, y: y), GridPoint(x: x - 1, y: y + 1), GridPoint(x: x + 1, y: y + 1), GridPoint(x: x - 1, y: y - 1), GridPoint(x: x + 1, y: y - 1)]
        
        for space in possibleMoves {
            if let boardSpace = getBoardSpace(at: space) {
                if boardSpace.type != .obstacle { availableSpaces.append(boardSpace) }
            }
        }
        
        return availableSpaces
    }
    
    func getChebyshevDistanceToGoal(space: BoardSpace) -> Int {
        let x = abs(goal!.gridPoint.x - space.gridPoint.x)
        let y = abs(goal!.gridPoint.y - space.gridPoint.y)
        return max(x, y)
    }
    
    func startAstar() {
        open.append(start!)
        g[start!.id.uuidString] = 0
        f[start!.id.uuidString] = getChebyshevDistanceToGoal(space: start!)
        parent[start!.id.uuidString] = nil
        
        while !open.isEmpty {
            let currentSpace = open.popLast()!
            
            if currentSpace.id == goal?.id {
                return
            }
            
            closed.append(currentSpace)
            
            let adjacentSpaces = getAvailableSpacesFromGridPoint(gridPoint: currentSpace.gridPoint)
            for adjacentSpace in adjacentSpaces {
                let key = adjacentSpace.id.uuidString
                if !open.contains(adjacentSpace) && !closed.contains(adjacentSpace) {
                    let distanceToGoal = getChebyshevDistanceToGoal(space: adjacentSpace)
                    g[key] = g[currentSpace.id.uuidString]! + 1
                    h[key] = distanceToGoal
                    f[key] = g[key]! + h[key]!
                    parent[key] = currentSpace
                    open.append(adjacentSpace)
                }
                else if (g[currentSpace.id.uuidString]! + 1 < g[key]!) {
                    g[key] = g[currentSpace.id.uuidString]! + 1
                    h[key] = getChebyshevDistanceToGoal(space: adjacentSpace)
                    f[key] = g[key]! + h[key]!
                    parent[key] = currentSpace
                    
                    if open.contains(adjacentSpace) {
                        open = open.sorted { lhs, rhs in
                            getChebyshevDistanceToGoal(space: lhs) > getChebyshevDistanceToGoal(space: rhs)
                        }
                    }
                    else if closed.contains(adjacentSpace) {
                        closed.remove(at: closed.firstIndex(of: adjacentSpace)!)
                        open.append(adjacentSpace)
                    }
                }
            }
        }
    }
    
    func getParents(space: BoardSpace) -> [BoardSpace] {
        var path = [space]
        
        var currentNode: BoardSpace? = space
        while parent[currentNode!.id.uuidString] != nil {
            let parent = parent[currentNode!.id.uuidString]
            if let parent = parent {
                path.append(parent!)
                currentNode = parent
            }
        }
        
        return path
    }
    
    func highlightPath(path: [BoardSpace]) {
        for space in path {
            space.highlight = true
        }
    }
}

