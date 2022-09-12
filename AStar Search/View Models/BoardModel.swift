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
    let scale = 2
    
    @Published var start: BoardSpace?
    @Published var goal: BoardSpace?
    
    var queue: [Path] = []
    var numberOfSpacesChecked = 0
    
    @Published var shortestPath: Path?
    @Published var currentPath = Path(spaces: [])
    @Published var currentSpace: BoardSpace?
    
    func createBoard() {
        
        resetBoard()
        
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
    
    func scaleBoard() {
        let newBoard = Board(rows: [])
        for row in 0..<boardSize * scale {
            let newRow = BoardRow(spaces: [])
            for col in 0..<boardSize * scale {
                newRow.spaces.append(BoardSpace(type: .empty, gridPoint: GridPoint(x: col, y: (boardSize * scale) - 1 - row)))
            }
            newBoard.rows.append(newRow)
        }
        
        if start != nil {
            let newStartSpaces = getScaledSpacesForSpace(scale: scale, space: start!)
            start = newStartSpaces[0]
            for space in newStartSpaces {
                if space.gridPoint.x < start!.gridPoint.x && space.gridPoint.y < start!.gridPoint.y {
                    start = newBoard.rows[space.gridPoint.y].spaces[space.gridPoint.x]
                }
            }
        }
        
        if goal != nil {
            let newGoalSpaces = getScaledSpacesForSpace(scale: scale, space: goal!)
            goal = newGoalSpaces[0]
            for space in newGoalSpaces {
                if space.gridPoint.x < goal!.gridPoint.x && space.gridPoint.y < goal!.gridPoint.y {
                    goal = newBoard.rows[((boardSize * scale) - 1) - space.gridPoint.y].spaces[space.gridPoint.x]
                }
            }
        }
        
        for (rowIndex, row) in board.rows.enumerated() {
            for (colIndex, _) in row.spaces.enumerated() {
                let gridPoint = GridPoint(x: colIndex, y: rowIndex)
                let space = getBoardSpace(at: gridPoint)!
                let points = getScaledSpacesForSpace(scale: scale, space: space)
                for point in points {
                    switch point.type {
                    case .start:
                        newBoard.rows[((boardSize * scale) - 1) - point.gridPoint.y].spaces[point.gridPoint.x].type = .empty
                    case .goal:
                        newBoard.rows[((boardSize * scale) - 1) - point.gridPoint.y].spaces[point.gridPoint.x].type = .empty
                    default:
                        newBoard.rows[((boardSize * scale) - 1) - point.gridPoint.y].spaces[point.gridPoint.x].type = point.type
                    }
                }
            }
        }
        
        if start != nil {
            newBoard.rows[((boardSize * scale) - 1) - start!.gridPoint.y].spaces[start!.gridPoint.x].type = .start
            currentPath = Path(spaces: [start!])
            queue.removeAll()
            queue.append(currentPath)
        }
        if goal != nil {
            newBoard.rows[((boardSize * scale) - 1) - goal!.gridPoint.y].spaces[goal!.gridPoint.x].type = .goal
        }
        
        board = newBoard
        boardSize *= scale
    }
    
    func getScaledSpacesForSpace(scale: Int, space: BoardSpace) -> [BoardSpace] {
        var spaces: [BoardSpace] = []
        
        let minX = space.gridPoint.x * scale
        let minY = space.gridPoint.y * scale
        
        let maxX = minX + (scale - 1)
        let maxY = minY + (scale - 1)
        
        for xSpace in minX...maxX {
            for ySpace in minY...maxY {
                spaces.append(BoardSpace(type: space.type, gridPoint: GridPoint(x: xSpace, y: ySpace)))
            }
        }
        
        return spaces
    }
    
    func resetBoard() {
        start = nil
        goal = nil
        queue.removeAll()
        shortestPath = nil
        currentSpace = nil
        currentPath.spaces.removeAll()
        boardSize = 10
        numberOfSpacesChecked = 0
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
            currentPath = Path(spaces: [start!])
            queue.removeAll()
            queue.append(currentPath)
            
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
    
    func boardContainsSpaceAtGridPoint(gridPoint: GridPoint) -> Bool {
        let xRange = 0...boardSize - 1
        let yRange = 0...boardSize - 1
        
        return (xRange.contains(gridPoint.x) && yRange.contains((gridPoint.y)))
    }
    
    func getBoardSpace(at gridPoint: GridPoint) -> BoardSpace? {
        guard boardContainsSpaceAtGridPoint(gridPoint: gridPoint) else { return nil }
        return board.rows[Int(boardSize - 1 - gridPoint.y)].spaces[gridPoint.x]
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
    
    func makeNextMove() {
        
        // Make sure current path's current distance + heuristic value is less than the shortest path's distance
        // No need to search a path that has no chance at being shorter
        if shortestPath != nil {
            guard getMinimumDistanceToGoal(path: currentPath) < shortestPath!.distance else {
                goToNextPath()
                return
            }
        }
        
        // Get available spaces for current path's most recent added space
        var availableSpaces = getAvailableSpacesFromGridPoint(gridPoint: currentPath.spaces.last!.gridPoint)
        
        // If path can not go anywhere due to obstacles, path is at dead end and should go to next path and restart
        guard !availableSpaces.isEmpty else {
            goToNextPath()
            return
        }
        
        // Remove all spaces from available spaces that have already been visited
        availableSpaces.removeAll { availableSpace in
            availableSpace.visited == true
        }
        
        // If path can not go anywhere due to all nearby spaces having already been visited, go to next path and restart
        guard !availableSpaces.isEmpty else {
            goToNextPath()
            return
        }
        
        // For all available spaces left, get each space's distance to goal
        for space in availableSpaces {
            space.distanceToGoal = getChebyshevDistanceToGoal(space: space)
            space.visited = true
            numberOfSpacesChecked += 1
        }
        
        // Get closest space to goal
        var closestSpace = availableSpaces[0]
        for space in availableSpaces {
            if space.distanceToGoal! < closestSpace.distanceToGoal! {
                closestSpace = space
            }
        }
        
        // Create new paths for spaces that are not closest
        for space in availableSpaces {
            if space != closestSpace {
                if shortestPath == nil || getMinimumDistanceToGoal(path: currentPath) < shortestPath!.distance {
                    let newPath = Path(spaces: currentPath.spaces)
                    newPath.spaces.append(space)
                    newPath.distance = currentPath.spaces.count
                    queue.append(newPath)
                }
            }
            else {
                // Go to next space in current path
                currentSpace?.isBeingLookedAt = false
                currentSpace = closestSpace
                
                currentPath.spaces.append(closestSpace)
                currentPath.distance += 1
                currentSpace?.isBeingLookedAt = true
            }
        }
        
        // Sort queue by distance traveled + heuristic
        queue = queue.sorted(by: { lhs, rhs in
            getMinimumDistanceToGoal(path: lhs) > getMinimumDistanceToGoal(path: rhs)
        })
        
        // Check if path is at end
        if currentSpace?.gridPoint == goal?.gridPoint {
            currentSpace?.isBeingLookedAt = false
            
            // Update shortest path if needed
            if shortestPath != nil {
                if currentPath.distance < shortestPath!.distance { shortestPath = currentPath }
            }
            else {
                shortestPath = currentPath
            }
            
            if !queue.isEmpty {
                goToNextPath()
            }
        }
    }
    
    func pathAsString(path: Path) -> String {
        var pathString = ""
        for space in path.spaces {
            pathString += "(\(space.gridPoint.x), \(space.gridPoint.y))"
        }
        return pathString
    }
    
    func highlightShortestPath(path: Path) {
        currentSpace?.isBeingLookedAt = false
        for space in path.spaces {
            if space.type != .start && space.type != .goal {
                space.inShortestPath = true
            }
        }
    }
    
    func getMinimumDistanceToGoal(path: Path) -> Int {
        return path.distance + getChebyshevDistanceToGoal(space: path.spaces.last!)
    }
    
    func goToNextPath() {
        currentSpace?.isBeingLookedAt = false
        currentPath = queue.popLast()!
        currentSpace = currentPath.spaces.last
        currentSpace?.isBeingLookedAt = true
    }
}

