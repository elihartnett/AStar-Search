//
//  BoardSpace.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import Foundation

class Board: Identifiable, ObservableObject {
    let id = UUID()
    @Published var rows: [BoardRow]
    
    init(rows: [BoardRow]) {
        self.rows = rows
    }
}
