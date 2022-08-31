//
//  ContentView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var board = Board(rows: [
    BoardRow(spaces: [BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty)]),
    BoardRow(spaces: [BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty)]),
    BoardRow(spaces: [BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty)]),
    BoardRow(spaces: [BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty), BoardSpace(type: .empty)])
    ])
    
    @State var setStart = false
    @State var setObstacle = false
    @State var setGoal = false
    
    var body: some View {
        
        VStack {
            
            Group {
                Button {
                    setStart = true
                } label: {
                    Text("Set Start")
                }
                
                Button {
                    setObstacle = true
                } label: {
                    Text("Create Obstacle")
                }
                
                Button {
                    setGoal = true
                } label: {
                    Text("Set Goal")
                }
            }
            
            VStack(spacing: 0) {
                
                ForEach($board.rows) { $row in
                    
                    HStack(spacing: 0) {
                        
                        ForEach($row.spaces) { $space in
                            
                            Rectangle()
                                .fill(getSpaceColor(type: space.type))
                                .border(.black)
                                .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                                .onTapGesture {
                                    if setStart {
                                        space.type = .start
                                        setStart = false
                                    }
                                    else if setObstacle {
                                        space.type = .obstacle
                                        setObstacle = false
                                    }
                                    else if setGoal {
                                        space.type = .goal
                                        setGoal = false
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

func getSpaceColor(type: SpaceType) -> Color {
    switch type {
    case .start:
        return .white
    case .empty:
        return .green
    case .obstacle:
        return .red
    case .goal:
        return .black
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
