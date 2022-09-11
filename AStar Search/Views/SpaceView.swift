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
            .fill(space.getColor())
            .overlay { space.overlay }
            .border(.black)
            .onTapGesture {
                boardModel.handleConfigurationTap(addSpaceType: addSpaceType, space: space)
            }
    }
}

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        SpaceView(boardModel: dev.boardModel, space: dev.boardModel.board.rows[0].spaces[0], addSpaceType: .start)
    }
}
