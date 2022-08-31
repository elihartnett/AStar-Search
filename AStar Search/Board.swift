//
//  BoardSpace.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import Foundation

struct Board: Identifiable {
    let id = UUID()
    var rows: [BoardRow]
}

struct BoardRow: Identifiable {
    let id = UUID()
    var spaces: [BoardSpace]
}

struct BoardSpace: Identifiable {
    let id = UUID()
    var type: SpaceType
}

enum SpaceType {
    case start
    case goal
    case empty
    case obstacle
}
