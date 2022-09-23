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
    @State var boardSize: Double = 500
    
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
                    DispatchQueue.main.async {
                        chartData.removeAll()
                        
                        boardModel.boardSize = Int(boardSize)
                        boardModel.reset()

                        chartData.append(Series(heuristic: .dijkstra, data: (inputSize: 0, time: Double(0.0))))
                        runDijkstra(size: Int(boardSize))
                    
                        chartData.append(Series(heuristic: .chebyshev, data: (inputSize: 0, time: Double(0.0))))
                        runChebyshev(size: Int(boardSize))
                        
    //                    runEuclidean(size: Int(size))
                    }
                } label: {
                    Image(systemName: "play.circle")
                }
                
                Text((boardSize * boardSize).formatted())
                
                Slider(value: $boardSize, in: 100...1000, step: 1)
            }
        }
        .padding()
    }
    
    func prepareForNext() {
        boardModel.open = PriorityQueue(ascending: true)
        boardModel.g = [String : Double]()
        boardModel.h = [String : Double]()
        boardModel.f = [String : Double]()
        boardModel.parent = [String : BoardSpace?]()
        for boardSpace in boardModel.board {
            boardSpace.closed = false
            boardSpace.open = false
        }
    }
    
        func runDijkstra(size: Int) {
            boardModel.heuristic = .dijkstra
            
            prepareForNext()
            
            let start = DispatchTime.now()
            boardModel.findShortestPathFromStartToGoal()
            let finish = DispatchTime.now()
            let timeInterval = Int(finish.uptimeNanoseconds - start.uptimeNanoseconds)
            
            chartData.append(Series(heuristic: .dijkstra, data: (inputSize: size, time: Double(timeInterval))))
        }
    
    func runChebyshev(size: Int) {
        boardModel.heuristic = .chebyshev
        
        prepareForNext()
        
        let start = DispatchTime.now()
        boardModel.findShortestPathFromStartToGoal()
        let finish = DispatchTime.now()
        let timeInterval = Int(finish.uptimeNanoseconds - start.uptimeNanoseconds)
        
        chartData.append(Series(heuristic: .chebyshev, data: (inputSize: size, time: Double(timeInterval))))
    }
    
    func runEuclidean(size: Int) {
            boardModel.heuristic = .euclidean
        
            prepareForNext()
                        
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

