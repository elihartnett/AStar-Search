//
//  GraphView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/22/22.
//

import SwiftUI
import Charts

struct GraphView: View {
    
    @StateObject var boardModel = BoardModel()
    @State var chartData: [Series] = []
    
    var body: some View {
        
        VStack {
            
            if chartData.isEmpty {
                Rectangle()
                    .fill(.gray)
            }
            else {
                Chart {
                    ForEach(chartData) { series in
                        LineMark(x: .value("Input Size", series.data.inputSize * series.data.inputSize), y: .value("Time", series.data.time), series: .value(series.heuristic.rawValue, series.heuristic.rawValue))
                            .foregroundStyle(by: .value("Heuristic", series.heuristic.rawValue))
                    }
                }
            }
            
            HStack {
                
                Button {
                    chartData.removeAll()

                    boardModel.boardSize = 10
                    boardModel.reset()
                    runDijkstra(size: 10)
                    runManhattan(size: 10)
                    runEuclidean(size: 10)
                                        
                    boardModel.boardSize = 100
                    boardModel.reset()
                    runDijkstra(size: 100)
                    runManhattan(size: 100)
                    runEuclidean(size: 100)
                                        
                    boardModel.boardSize = 200
                    boardModel.reset()
                    runDijkstra(size: 200)
                    runManhattan(size: 200)
                    runEuclidean(size: 200)
                                        
                    boardModel.boardSize = 500
                    boardModel.reset()
                    runDijkstra(size: 500)
                    runManhattan(size: 500)
                    runEuclidean(size: 500)
                                        
                    boardModel.boardSize = 1000
                    boardModel.reset()
                    runDijkstra(size: 1000)
                    runManhattan(size: 1000)
                    runEuclidean(size: 1000)
                } label: {
                    Image(systemName: "play.circle")
                }
            }
        }
        .padding()
    }
    
    func runDijkstra(size: Int) {
        boardModel.heuristic = .dijkstra
        
        boardModel.prepareForNext()
        
        let start = DispatchTime.now()
        boardModel.findShortestPathFromStartToGoal()
        let finish = DispatchTime.now()
        let timeInterval = Int(finish.uptimeNanoseconds - start.uptimeNanoseconds)
        
        chartData.append(Series(heuristic: .dijkstra, data: (inputSize: size, time: Double(timeInterval))))
    }
    
    func runManhattan(size: Int) {
        boardModel.heuristic = .manhattan
        
        boardModel.prepareForNext()
        
        let start = DispatchTime.now()
        boardModel.findShortestPathFromStartToGoal()
        let finish = DispatchTime.now()
        let timeInterval = Int(finish.uptimeNanoseconds - start.uptimeNanoseconds)
        
        chartData.append(Series(heuristic: .manhattan, data: (inputSize: size, time: Double(timeInterval))))
    }
    
    func runEuclidean(size: Int) {
        boardModel.heuristic = .euclidean
        
        boardModel.prepareForNext()
        
        let start = DispatchTime.now()
        boardModel.findShortestPathFromStartToGoal()
        let finish = DispatchTime.now()
        let timeInterval = Int(finish.uptimeNanoseconds - start.uptimeNanoseconds)
        
        chartData.append(Series(heuristic: .euclidean, data: (inputSize: size, time: Double(timeInterval))))
    }
}

struct Series: Identifiable {
    let id = UUID()
    
    let heuristic: Heuristic
    
    let data: (inputSize: Int, time: Double)
}

