//
//  Path.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/3/22.
//

import Foundation

class Path: Identifiable {
    let id = UUID()
    var spaces: [BoardSpace]
    var distance = 0
    
    init(spaces: [BoardSpace], distance: Int = 0) {
        self.spaces = spaces
        self.distance = distance
    }
}
