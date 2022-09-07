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
    
    var queue: [Path] = []
    var shortestPath: Path?

    var currentSpace: BoardSpace?
    var visitedSpaces: [BoardSpace] = []
    
    func createBoard() {
        start = nil
        goal = nil
        queue.removeAll()
        shortestPath = nil
        currentSpace = nil
        visitedSpaces.removeAll()
        
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
        
        let moveUp = GridPoint(x: x, y: y + 1)
        let moveDown = GridPoint(x: x, y: y - 1)
        let moveLeft = GridPoint(x: x - 1, y: y)
        let moveRight = GridPoint(x: x + 1, y: y)
        
        if let space = getBoardSpace(at: moveUp) {
            if space.type != .obstacle { availableSpaces.append(space) }
        }
        if let space = getBoardSpace(at: moveDown) {
            if space.type != .obstacle { availableSpaces.append(space) }
        }
        if let space = getBoardSpace(at: moveLeft) {
            if space.type != .obstacle { availableSpaces.append(space) }
        }
        if let space = getBoardSpace(at: moveRight) {
            if space.type != .obstacle { availableSpaces.append(space) }
        }
        
        return availableSpaces
    }
    
    func getEuclideanDistanceToGoal(space: BoardSpace) -> Double {
        let a = abs(goal!.gridPoint.x - space.gridPoint.x)
        let b = abs(goal!.gridPoint.y - space.gridPoint.y)
        return sqrt(Double((a*a) + (b*b)))
    }
    
    func findShortestPath() {
        currentSpace = start
        visitedSpaces.append(start!)
        
        // Figure out which direction current space can move to
        var availableSpaces = getAvailableSpacesFromGridPoint(gridPoint: currentSpace!.gridPoint)
        
        // Create paths from available spaces
        for space in availableSpaces {
            space.distanceFromGoal = getEuclideanDistanceToGoal(space: space)
            let path = Path(spaces: [space])
            queue.append(path)
        }
        
        // Sort queue of available paths by distance to goal in descending order (shortest on top)
        queue = queue.sorted { lhs, rhs in
            return (lhs.spaces.last?.distanceFromGoal)! > (rhs.spaces.last?.distanceFromGoal)!
        }
        
        while !queue.isEmpty {
            print("Exploring path with root: \(queue.last?.spaces.last?.gridPoint)")
            explorePath(queue.popLast()!)
        }
        print("-----")
        for space in shortestPath!.spaces {
            space.type = .obstacle
        }
    }
    
    func explorePath(_ path: Path) {
        
        currentSpace = path.spaces.first
        
        var finishedWithPath = false
        while !finishedWithPath {
            // Figure out which direction current space can move to
            var availableSpaces = getAvailableSpacesFromGridPoint(gridPoint: currentSpace!.gridPoint)
            
            // Remove spaces that have already been visited
            availableSpaces.removeAll { availableSpace in
                visitedSpaces.contains { vistedSpace in
                    availableSpace == vistedSpace
                }
            }

            guard !availableSpaces.isEmpty else { return }
            
            var minDistanceToGoal = getEuclideanDistanceToGoal(space: availableSpaces.first!)
            // Figure out which move is closest to goal
            for space in availableSpaces {
                space.distanceFromGoal = getEuclideanDistanceToGoal(space: space)
                print("Got distance for \(space.gridPoint)")
                visitedSpaces.append(space)
                if let shortestPathDistance = shortestPath?.distance {
                    if (space.distanceFromGoal! + Double(path.distance) > Double(shortestPathDistance)) {
                        print("just gonna abort")
                        let index = availableSpaces.firstIndex(of: space)
                        availableSpaces.remove(at: index!)
                        continue
                    }
                }
                if space.distanceFromGoal! < minDistanceToGoal {
                    minDistanceToGoal = space.distanceFromGoal!
                }
            }
            
            guard !availableSpaces.isEmpty else { return }
            
            // Create available paths from available spaces
            for space in availableSpaces {
                if space.distanceFromGoal! != minDistanceToGoal {
                    let path = Path(spaces: [space])
                    queue.append(path)
                }
                else {
                    currentSpace = space
                    visitedSpaces.append(space)
                    path.distance += 1
                    path.spaces.append(space)
                }
            }
            
            // Sort queue of available paths by distance to goal in descending order (shortest on top)
            queue = queue.sorted { lhs, rhs in
                return (lhs.spaces.last?.distanceFromGoal)! > (rhs.spaces.last?.distanceFromGoal)!
            }
            
            if currentSpace?.gridPoint == goal?.gridPoint {
                finishedWithPath = true
                if shortestPath == nil {
                    shortestPath = path
                }
                if path.distance < shortestPath!.distance {
                    shortestPath = path
                }
            }
        }
    }
}
