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
    @State var dragsPoints: [CGPoint] = []
    
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
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(boardModel: dev.boardModel, addSpaceType: .start)
    }
}
