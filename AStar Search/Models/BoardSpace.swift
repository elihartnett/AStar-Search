//
//  BoardSpace.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation
import SwiftUI

class BoardSpace: Identifiable, Hashable, ObservableObject {
    
    let id = UUID()
    var gridPoint: GridPoint
    @Published var type: SpaceType
    @Published var highlight = false
    
    init(type: SpaceType, gridPoint: GridPoint) {
        self.type = type
        self.gridPoint = gridPoint
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BoardSpace, rhs: BoardSpace) -> Bool {
        lhs.id == rhs.id
    }

}

struct GridPoint: Equatable {
    var x: Int
    var y: Int
}
