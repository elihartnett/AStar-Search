//
//  BoardModel.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation
import SwiftUI

class BoardModel: ObservableObject {
    
    @Published var board: [BoardSpace] = []
    var boardSize = 50
    
    var startPoint = GridPoint(x: 0, y: 0)
    var goalPoint = GridPoint(x: 0, y: 0)
    
    var heuristic: Heuristic = .chebyshev
    
    var open: PriorityQueue<BoardSpace> = PriorityQueue(ascending: true)
    // Distance from start node
    var g = [String : Int]()
    // Lower bound heuristic on optimal path cost to goal node
    var h = [String : Int]()
    // Optimal cost from start to goal
    var f = [String : Int]()
    var parent = [String : BoardSpace?]()
    
    func createBoard() {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let randomInt = Int.random(in: 1...5)
                board.append(BoardSpace(gridPoint: GridPoint(x: col, y: row), type: randomInt == 5 ? .obstacle : .empty))
            }
        }
        
        startPoint = generateRandomPoint()
        let start = getBoardSpace(at: startPoint)
        start?.type = .start
        
        goalPoint = generateRandomPoint()
        let goal = getBoardSpace(at: goalPoint)
        goal?.type = .goal
    }
    
    func generateRandomPoint() -> GridPoint {
        let x = Int.random(in: 0..<boardSize)
        let y = Int.random(in: 0..<boardSize)
        return GridPoint(x: x, y: y)
    }
    
    func reset() {
        board.removeAll()
        startPoint = GridPoint(x: 0, y: 0)
        goalPoint = GridPoint(x: 0, y: 0)
        
        createBoard()
    }
    
    func boardContainsSpaceAtGridPoint(gridPoint: GridPoint) -> Bool {
        return 0..<boardSize ~= gridPoint.x && 0..<boardSize ~= gridPoint.y
    }
    
    func getBoardSpace(at gridPoint: GridPoint) -> BoardSpace? {
        guard boardContainsSpaceAtGridPoint(gridPoint: gridPoint) else { return nil }
        return board[(gridPoint.y * boardSize) + gridPoint.x]
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
        let x = abs(goalPoint.x - space.gridPoint.x)
        let y = abs(goalPoint.y - space.gridPoint.y)
        return max(x, y)
    }
    
    func findShortestPathFromStartToGoal() {
        let startSpace = getBoardSpace(at: startPoint)!
        let goalSpace = getBoardSpace(at: goalPoint)!
        
        open.push(startSpace)
        let key = startSpace.id.uuidString
        g[key] = 0
        h[key] = getChebyshevDistanceToGoal(space: startSpace)
        f[key] = h[key]
        parent[key] = nil
        
        while !open.isEmpty {
            let currentSpace = open.pop()!
            
            if currentSpace.id == goalSpace.id && open.count == 0 {
                return
            }
            
            currentSpace.closed = true
            
            let adjacentSpaces = getAvailableSpacesFromGridPoint(gridPoint: currentSpace.gridPoint)
            for adjacentSpace in adjacentSpaces {
                let key = adjacentSpace.id.uuidString
                if !open.contains(adjacentSpace) && !adjacentSpace.closed {
                    let distanceToGoal = getChebyshevDistanceToGoal(space: adjacentSpace)
                    g[key] = g[currentSpace.id.uuidString]! + 1
                    h[key] = distanceToGoal
                    f[key] = g[key]! + h[key]!
                    adjacentSpace.priority = f[key]!
                    parent[key] = currentSpace
                    open.push(adjacentSpace)
                }
                else if (g[currentSpace.id.uuidString]! + 1 < g[key]!) {
                    g[key] = g[currentSpace.id.uuidString]! + 1
                    h[key] = getChebyshevDistanceToGoal(space: adjacentSpace)
                    f[key] = g[key]! + h[key]!
                    adjacentSpace.priority = f[key]!
                    parent[key] = currentSpace
                    
                    if open.contains(adjacentSpace) {
                        let adjacentSpace = getBoardSpace(at: adjacentSpace.gridPoint)
                        adjacentSpace?.priority -= 1
                    }
                    else if adjacentSpace.closed {
                        adjacentSpace.closed.toggle()
                        open.push(adjacentSpace)
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
            space.highlighted = true
        }
    }
}

