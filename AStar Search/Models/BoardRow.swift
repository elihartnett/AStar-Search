//
//  BoardRow.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation

class BoardRow: Identifiable, ObservableObject {
    let id = UUID()
    @Published var spaces: [BoardSpace]
    
    init(spaces: [BoardSpace]) {
        self.spaces = spaces
    }
}
