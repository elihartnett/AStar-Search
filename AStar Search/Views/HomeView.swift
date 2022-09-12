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
                                
                VStack {
                    Rectangle()
                        .fill(.yellow.opacity(0.5))
                        .frame(width: 25, height: 25)
                    Text("Currently viewing")
                }
                .padding()
                
                VStack {
                    Rectangle()
                        .fill(.yellow)
                        .frame(width: 25, height: 25)
                    Text("In shortest path")
                }
                .padding()
                
                VStack {
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .frame(width: 25, height: 25)
                    Text("Checked")
                }
                .padding()
            }
            .padding()
            .background { Color.gray.opacity(0.5)}
            
            BoardView(boardModel: boardModel, addSpaceType: addSpaceType)
                .onAppear {
                    boardModel.createBoard()
                }
            
            // Menu buttons
            HStack {
                
                Spacer()
                
                Button {
                    boardModel.createBoard()
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
                    
                    if !boardModel.queue.isEmpty {
                        boardModel.makeNextMove()
                    }
                    else {
                        boardModel.highlightShortestPath(path: boardModel.shortestPath!)
                    }
                } label: {
                    VStack {
                        Image(systemName: "forward.frame")
                        Text("Move")
                    }
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
                    boardModel.highlightShortestPath(path: boardModel.shortestPath!)
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
            
            
            ScrollView {
                
                VStack {
                    if let shortestPath = boardModel.shortestPath {
                        Text("Current best path (\(shortestPath.spaces.count - 1) moves): \(boardModel.pathAsString(path: shortestPath))")
                    }
                    
                    Text("\(boardModel.numberOfSpacesChecked) / \(boardModel.boardSize * boardModel.boardSize) nodes checked")
                        .padding()
                    
                    Text("Current path: [ \(boardModel.pathAsString(path: boardModel.currentPath))]")
                        .padding()
                    
                    Text("Queue:").bold().underline()
                    
                    if boardModel.start != nil && boardModel.goal != nil {
                        ForEach(0..<boardModel.queue.count, id: \.self) { index in
                            let path = boardModel.queue[boardModel.queue.count - 1 - index]
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
