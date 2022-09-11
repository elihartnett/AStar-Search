//
//  Board.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import Foundation

class Board: Identifiable {
    let id = UUID()
    var rows: [BoardRow]
    
    init(rows: [BoardRow]) {
        self.rows = rows
    }
}
