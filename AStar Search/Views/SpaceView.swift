//
//  SpaceView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import SwiftUI

struct SpaceView: View {
    
    @ObservedObject var boardModel: BoardModel
    @ObservedObject var space: BoardSpace
    var addSpaceType: SpaceType
    
    var body: some View {
        
        // Display space (start - white, empty - green, obstacle - red, goal - black)
        // Space may be tinted with light black if it has been looked at or yellow if it is apart of the shortest path
        Rectangle()
            .fill(getColor())
            .overlay { space.visited ? Color.black.opacity(0.3) : Color.clear }
            .overlay { space.isBeingLookedAt ? Color.yellow.opacity(0.5) : Color.clear }
            .overlay { space.inShortestPath ? Color.yellow : Color.clear }
            .border(.black)
            .onTapGesture {
                boardModel.handleConfigurationTap(addSpaceType: addSpaceType, space: space)
            }
    }
    
    func getColor() -> Color {
        switch space.type {
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

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        SpaceView(boardModel: dev.boardModel, space: dev.boardModel.board.rows[0].spaces[0], addSpaceType: .start)
    }
}
