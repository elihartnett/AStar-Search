//
//  Enums.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation

enum SpaceType: String {
    case start = "0"
    case goal = "1"
    case empty = "2"
    case obstacle = "3"
}

enum Moves {
    case up
    case down
    case left
    case right
}
