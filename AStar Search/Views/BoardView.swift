//
//  BoardView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import SwiftUI

struct BoardView: View {
    
    @ObservedObject var boardModel: BoardModel
    var addSpaceType: SpaceType
    
    var body: some View {
        
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                ForEach(boardModel.board.rows) { row in
                    
                    HStack(spacing: 0) {
                        
                        ForEach(row.spaces) { space in
                            
                            SpaceView(boardModel: boardModel, space: space, addSpaceType: addSpaceType)
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let rowPercent = value.location.x / geo.size.width
                        let heightPercent = value.location.y / geo.size.height
                        
                        let row = Int(floor(rowPercent * CGFloat(boardModel.boardSize)))
                        let col = Int(floor(heightPercent * CGFloat(boardModel.boardSize)))
                        
                        if let space = boardModel.getBoardSpace(at: GridPoint(x: row, y: boardModel.boardSize - 1 - col)) {
                            boardModel.handleConfigurationTap(addSpaceType: addSpaceType, space: space)
                        }
                    })
            )
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(boardModel: dev.boardModel, addSpaceType: .start)
    }
}
