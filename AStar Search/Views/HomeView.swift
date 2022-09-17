//
//  HomeView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var boardModel = BoardModel()
    @State var showAlert = false
    @State var alertMessage = ""
    @State var boardSize = 50.0
    
    var body: some View {
        
        VStack {
            
            // Legend
            HStack {
                
                Spacer()
                
                VStack {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 25, height: 25)
                    Text("Start")
                }
                
                Spacer()
                
                VStack {
                    Rectangle()
                        .fill(.white)
                        .frame(width: 25, height: 25)
                    Text("Empty")
                }
                
                Spacer()
                
                VStack {
                    Rectangle()
                        .fill(.red)
                        .frame(width: 25, height: 25)
                    Text("Obstacle")
                }
                
                Spacer()
                
                VStack {
                    Rectangle()
                        .fill(.black)
                        .frame(width: 25, height: 25)
                    Text("Goal")
                }
                
                Spacer()
            }
            .padding(30)
            
            // Board
            VStack(spacing: 0) {
                ForEach(0..<(boardModel.board.count / boardModel.boardSize), id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<boardModel.boardSize, id: \.self) { colIndex in
                            SpaceView(space: boardModel.getBoardSpace(at: GridPoint(x: colIndex, y: rowIndex))!)
                        }
                    }
                }
            }
            .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
            .onAppear {
                boardModel.createBoard()
            }
            
            // Actions
            VStack {
                Slider(value: $boardSize, in: 3...100, step: 1)
                
                HStack {
                    
                    Button {
                        boardModel.boardSize = Int(boardSize)
                        boardModel.reset()
                    } label: {
                        VStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Randomize")
                        }
                    }
                    
                    Button {
                        DispatchQueue.global(qos: .userInitiated).async {
                            boardModel.boardSize = Int(boardSize)
                            
                            boardModel.findShortestPathFromStartToGoal()
                            
                            DispatchQueue.main.async {
                                var path = boardModel.getParents(space: boardModel.getBoardSpace(at: boardModel.goalPoint)!)
                                guard path.count >= 2 else {
                                    alertMessage = "No path found"
                                    showAlert = true
                                    return
                                }
                                path.remove(at: 0)
                                path.remove(at: path.count - 1)
                                boardModel.highlightPath(path: path)
                            }
                        }
                    } label: {
                        VStack {
                            Image(systemName: "play.circle")
                            Text("Start")
                        }
                    }
                    .disabled(Int(boardSize) != boardModel.boardSize)
                    
                    Picker("Picker", selection: $boardModel.heuristic) {
                        Text("Chebyshev")
                            .tag(Heuristic.chebyshev)
                        Text("Manhatten")
                            .tag(Heuristic.manhatten)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.5))
        .ignoresSafeArea()
        .alert(alertMessage, isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
