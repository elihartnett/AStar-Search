//
//  BoardSpace.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation

class BoardSpace: Identifiable, ObservableObject {
    let id = UUID()
    var x = 0
    var y = 0
    @Published var type: SpaceType
    
    init(type: SpaceType, x: Int, y: Int) {
        self.type = type
        self.x = x
        self.y = y
    }
}
