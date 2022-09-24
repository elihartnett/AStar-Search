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
    var boardSize = 25
    var timeToSolve = 0.0
    
    var startPoint = GridPoint(x: 0, y: 0)
    var goalPoint = GridPoint(x: 0, y: 0)
    
    var heuristic: Heuristic = .manhattan
    
    var open: PriorityQueue<BoardSpace> = PriorityQueue(ascending: true)
    // Distance from start node
    var g = [String : Double]()
    // Lower bound heuristic on optimal path cost to goal node
    var h = [String : Double]()
    // Optimal cost from start to goal
    var f = [String : Double]()
    var parent = [String : BoardSpace?]()
    
    init() {
        createBoard()
    }
    
    func createBoard() {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let randomInt = Int.random(in: 1...10)
                board.append(BoardSpace(gridPoint: GridPoint(x: col, y: row), type: randomInt == 10 ? .obstacle : .empty))
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
        
        let possibleMoves = [GridPoint(x: x, y: y + 1), GridPoint(x: x, y: y - 1), GridPoint(x: x - 1, y: y), GridPoint(x: x + 1, y: y)]
        
        for space in possibleMoves {
            if let boardSpace = getBoardSpace(at: space) {
                if boardSpace.type != .obstacle { availableSpaces.append(boardSpace) }
            }
        }
        
        return availableSpaces
    }
    
    func getManhattanDistanceToGoal(space: BoardSpace) -> Int {
        let x = abs(goalPoint.x - space.gridPoint.x)
        let y = abs(goalPoint.y - space.gridPoint.y)
        return x + y
    }
    
    func getEuclideanDistanceToGoal(space: BoardSpace) -> Double {
        let a = goalPoint.x - space.gridPoint.x
        let b = goalPoint.y - space.gridPoint.y
        return sqrt(Double((a*a) + (b*b)))
    }
    
    func getHeuristicValue(space: BoardSpace) -> Double {
        switch heuristic {
        case .dijkstra:
            return 0
        case .manhattan:
            return Double(getManhattanDistanceToGoal(space: space))
        case .euclidean:
            return getEuclideanDistanceToGoal(space: space)
        }
    }
    
    func findShortestPathFromStartToGoal() {
        let start = DispatchTime.now()
        
        let startSpace = getBoardSpace(at: startPoint)!
        let goalSpace = getBoardSpace(at: goalPoint)!
        
        open.push(startSpace)
        startSpace.open = true
        let key = startSpace.id.uuidString
        g[key] = 0
        h[key] = getHeuristicValue(space: startSpace)
        f[key] = h[key]
        parent[key] = nil
        
        while !open.isEmpty {
            let currentSpace = open.pop()!
            currentSpace.open = false
            
            if currentSpace.id == goalSpace.id {
                break
            }
            
            currentSpace.closed = true
            
            let adjacentSpaces = getAvailableSpacesFromGridPoint(gridPoint: currentSpace.gridPoint)
            for adjacentSpace in adjacentSpaces {
                let key = adjacentSpace.id.uuidString
                if !adjacentSpace.open && !adjacentSpace.closed {
                    let distanceToGoal = getHeuristicValue(space: adjacentSpace)
                    g[key] = g[currentSpace.id.uuidString]! + 1
                    h[key] = distanceToGoal
                    f[key] = g[key]! + h[key]!
                    adjacentSpace.priority = f[key]!
                    parent[key] = currentSpace
                    open.push(adjacentSpace)
                    adjacentSpace.open = true
                }
                else if (g[currentSpace.id.uuidString]! + 1 < g[key]!) {
                    g[key] = g[currentSpace.id.uuidString]! + 1
                    h[key] = getHeuristicValue(space: adjacentSpace)
                    f[key] = g[key]! + h[key]!
                    adjacentSpace.priority = f[key]!
                    
                    if adjacentSpace.open {
                        let adjacentSpace = getBoardSpace(at: adjacentSpace.gridPoint)
                        let newBoardSpace = BoardSpace(gridPoint: adjacentSpace!.gridPoint, type: adjacentSpace!.type)
                        newBoardSpace.id = adjacentSpace!.id
                        newBoardSpace.open = adjacentSpace!.open
                        newBoardSpace.closed = adjacentSpace!.closed
                        newBoardSpace.priority = adjacentSpace!.priority
                        newBoardSpace.highlighted = adjacentSpace!.highlighted
                        
                        open.remove(adjacentSpace!)
                        open.push(newBoardSpace)
                        adjacentSpace?.open = true
                    }
                    else if adjacentSpace.closed {
                        adjacentSpace.closed.toggle()
                        open.push(adjacentSpace)
                        adjacentSpace.open = true
                    }
                }
            }
        }
        
        let finish = DispatchTime.now()
        self.timeToSolve = Double(finish.uptimeNanoseconds - start.uptimeNanoseconds) / 1000000000
    }
    
    func prepareForNext() {
        open = PriorityQueue(ascending: true)
        g = [String : Double]()
        h = [String : Double]()
        f = [String : Double]()
        parent = [String : BoardSpace?]()
        for boardSpace in board {
            boardSpace.closed = false
            boardSpace.open = false
            boardSpace.highlighted = false
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
    
    func unHighlightPath(path: [BoardSpace]) {
        for space in path {
            space.highlighted = false
        }
    }
}

