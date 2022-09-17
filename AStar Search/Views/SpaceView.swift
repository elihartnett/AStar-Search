//
//  SpaceView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import SwiftUI

struct SpaceView: View {
    
    @ObservedObject var space: BoardSpace
    
    var body: some View {
        
        Rectangle()
            .fill(getColor())
            .border(.black)
            .overlay { space.highlighted ? Color.yellow.opacity(0.5) : .clear}
    }
    
    func getColor() -> Color {
        switch space.type {
        case .start:
            return .green
        case .empty:
            return .white
        case .obstacle:
            return .red
        case .goal:
            return .black
        }
    }
}
