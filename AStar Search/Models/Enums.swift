//
//  Enums.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/16/22.
//

import Foundation


enum SpaceType {
    case start
    case goal
    case obstacle
    case empty
}

enum Heuristic: String {
    case dijkstra = "Dijkstra"
    case chebyshev = "Chebyshev"
    case euclidean = "Euclidean"
}
