//
//  Visualizer.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/22/22.
//

import SwiftUI

struct VisualizerView: View {
    
    @StateObject var boardModel = BoardModel()
    @State var showAlert = false
    @State var alertMessage = ""
    @State var boardSize = 25.0
    
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
                
                Group {
                    VStack {
                        Rectangle()
                            .fill(.yellow.opacity(0.5))
                            .frame(width: 25, height: 25)
                        Text("Shortest Path")
                    }
                    
                    Spacer()
                }
            }
            .padding(30)
            
            // Board
            if boardModel.board.isEmpty {
                Rectangle()
                    .fill(.gray)
            }
            else {
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
                        boardModel.prepareForNext()
                        boardModel.boardSize = Int(boardSize)
                        boardModel.findShortestPathFromStartToGoal()
                        
                        var path = boardModel.getParents(space: boardModel.getBoardSpace(at: boardModel.goalPoint)!)
                        guard path.count >= 2 else {
                            alertMessage = "No path found"
                            showAlert = true
                            return
                        }
                        path.remove(at: 0)
                        path.remove(at: path.count - 1)
                        boardModel.highlightPath(path: path)
                        alertMessage = "Time to solve \(Int(pow(Double(boardModel.boardSize), 2))) node grid: \(boardModel.timeToSolve.description) seconds. Path size: \(path.count)"
                        showAlert = true
                    } label: {
                        VStack {
                            Image(systemName: "play.circle")
                            Text("Start")
                        }
                    }
                    .disabled(Int(boardSize) != boardModel.boardSize)
                    
                    Text((boardSize * boardSize).formatted())
                    
                    Picker("Picker", selection: $boardModel.heuristic) {
                        Text("Dijkstra")
                            .tag(Heuristic.dijkstra)
                        Text("Manhattan")
                            .tag(Heuristic.manhattan)
                        Text("Euclidean")
                            .tag(Heuristic.euclidean)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.5))
        .alert(alertMessage, isPresented: $showAlert) {
            Button("Ok", role: .cancel) { }
        }
    }
}

struct Visualizer_Previews: PreviewProvider {
    static var previews: some View {
        VisualizerView()
    }
}
