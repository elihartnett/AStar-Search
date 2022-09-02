//
//  BoardSpace.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation
import SwiftUI

class BoardSpace: Identifiable, ObservableObject {
    let id = UUID()
    var gridPoint: GridPoint
    @Published var type: SpaceType
    var distanceFromGoal: Double?
    
    init(type: SpaceType, gridPoint: GridPoint) {
        self.type = type
        self.gridPoint = gridPoint
    }
    
    func getColor() -> Color {
        switch type {
        case .start:
            return .white
        case .empty:
            return .green
        case .obstacle:
            return .red
        case .goal:
            return .black
        }
    }
}
