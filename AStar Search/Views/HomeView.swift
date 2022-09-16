//
//  HomeView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var boardModel = BoardModel()
    @State var addSpaceType: SpaceType = .start
    @State var showAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        
        VStack {
            
            // Picker
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
            
            // Legend
            HStack {
                
                VStack {
                    Rectangle()
                        .fill(.white)
                        .frame(width: 25, height: 25)
                    Text("Start")
                }
                .padding()
                
                VStack {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 25, height: 25)
                    Text("Empty")
                }
                .padding()
                
                VStack {
                    Rectangle()
                        .fill(.red)
                        .frame(width: 25, height: 25)
                    Text("Obstacle")
                }
                .padding()
                
                VStack {
                    Rectangle()
                        .fill(.black)
                        .frame(width: 25, height: 25)
                    Text("Goal")
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background { Color.gray.opacity(0.5)}
            
            BoardView(boardModel: boardModel, addSpaceType: addSpaceType)
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .onAppear {
                    boardModel.board = boardModel.createBoard(boardSize: 10)
                }
            
            // Menu buttons
            HStack {
                
                Spacer()
                
                Button {
                    boardModel.resetBoard()
                } label: {
                    VStack {
                        Image(systemName: "clear")
                        Text("Reset")
                    }
                }
                
                Spacer()
                
                Button {
                    boardModel.scaleBoard()
                } label: {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Scale")
                    }
                }
                
                Spacer()
                
                Button {
                    guard boardModel.start != nil && boardModel.goal != nil else {
                        alertMessage = "Please make sure you have selected start and goal nodes."
                        showAlert = true
                        return
                    }
                    
                    boardModel.startAstar()
                    var path = boardModel.getParents(space: boardModel.goal!)
                    path.remove(at: 0)
                    path.remove(at: path.count - 1)
                    boardModel.highlightPath(path: path)
                } label: {
                    VStack {
                        Image(systemName: "forward.end.alt")
                        Text("Skip to end")
                    }
                }
                
                Spacer()
                
            }
            .padding()
            .alert(alertMessage, isPresented: $showAlert) {
                Button("Ok", role: .cancel) { }
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
