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
    @State var hasMadeFirstMove = false
    @State var showAlert = false
    @State var alertMessage = ""
    
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
            
            BoardView(boardModel: boardModel, addSpaceType: addSpaceType)
                .onAppear {
                    boardModel.createBoard()
                }
            
            HStack {
                
                Spacer()
                
                Button {
                    boardModel.createBoard()
                } label: {
                    Text("Reset")
                }
                
                Spacer()
                
                Button {
                    guard boardModel.start != nil && boardModel.goal != nil else {
                        alertMessage = "Please make sure you have selected start and goal nodes."
                        showAlert = true
                        return
                    }
                    boardModel.scaleBoard()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                
                Spacer()
                
                Button {
                    guard boardModel.start != nil && boardModel.goal != nil else {
                        alertMessage = "Please make sure you have selected start and goal nodes."
                        showAlert = true
                        return
                    }
                    
                    if !boardModel.queue.isEmpty {
                        boardModel.makeNextMove()
                    }
                    else {
                        boardModel.highlightShortestPath()
                    }
                } label: {
                    Image(systemName: "forward.frame")
                }
                
                Spacer()
                
                Button {
                    guard boardModel.start != nil && boardModel.goal != nil else {
                        alertMessage = "Please make sure you have selected start and goal nodes."
                        showAlert = true
                        return
                    }
                    
                    while !boardModel.queue.isEmpty {
                        boardModel.makeNextMove()
                    }
                    
                    guard boardModel.shortestPath != nil else {
                        alertMessage = "No path found."
                        showAlert = true
                        return
                    }
                    boardModel.highlightShortestPath()
                } label: {
                    Image(systemName: "forward.end.alt")
                }
                
                Spacer()
                
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("Ok", role: .cancel) { }
            }

            
            ScrollView {
                
                VStack {
                    if let shortestPath = boardModel.shortestPath {
                        Text("Current best path (\(shortestPath.spaces.count - 1) moves): \(boardModel.pathAsString(path: shortestPath))")
                    }
                    
                    Text("\(boardModel.visitedSpaces.count) / \(boardModel.boardSize * boardModel.boardSize) nodes checked")
                        .padding()
                    
                    Text("Queue:").bold().underline()
                    
                    if boardModel.start != nil && boardModel.goal != nil {
                        ForEach(boardModel.queue) { path in
                            HStack {
                                Text("Minimum distance: \(boardModel.getMinimumDistanceToGoal(path: path))").bold()
                                    .background {
                                        Color(uiColor: path.id == boardModel.currentPath.id ? .yellow : .clear)
                                    }
                                Text(boardModel.pathAsString(path: path))
                            }
                            Divider()
                        }
                        
                    }
                }
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
