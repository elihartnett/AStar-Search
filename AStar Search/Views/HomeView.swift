//
//  HomeView.swift
//  AStar Search
//
//  Created by Eli Hartnett on 8/30/22.
//

import SwiftUI

struct HomeView: View {
    
    @State var selectedTab: Tab = .visualizer
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            VisualizerView()
                .tabItem({
                    Label("Visualizer", systemImage: "square.grid.3x3.fill")
                })
                .tag(Tab.visualizer)
            
            GraphView()
                .tabItem {
                    Label("Grapher", systemImage: "speedometer")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

enum Tab {
    case visualizer
    case grapher
}
