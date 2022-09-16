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
        
        Rectangle()
            .fill(getColor())
            .border(.black)
            .overlay { space.highlight ? Color.yellow.opacity(0.4) : .clear}
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
