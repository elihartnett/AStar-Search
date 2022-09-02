//
//  ContentView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var boardModel = BoardModel()
    @State var addSpaceType: SpaceType = .start
    
    var body: some View {
        
        VStack {
            
            Picker("Picker", selection: $addSpaceType) {
                Text("Start")
                    .tag(SpaceType.start)
                Text("Empty")
                    .tag(SpaceType.empty)
                Text("Obstacle")
                    .tag(SpaceType.obstacle)
                Text("Goal")
                    .tag(SpaceType.goal)
            }
            .pickerStyle(.segmented)
            
            Slider(value: $boardModel.boardSize, in: 5...15, step: 1) { _ in
                boardModel.createBoard()
            }
            
            BoardView(boardModel: boardModel, addSpaceType: addSpaceType)
                .onAppear {
                    boardModel.createBoard()
                }
            
            Button {
                print(boardModel.getAvailableMoves(space: boardModel.start!))
            } label: {
                Text("Submit")
            }
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
