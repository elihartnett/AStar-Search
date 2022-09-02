//
//  Extensions.swift
//  AStar Search
//
//  Created by Eli Hartnett on 9/1/22.
//

import Foundation
import SwiftUI

class DeveloperPreview {
    
    static let instance = DeveloperPreview()
    
    private init() { }
    
    let boardModel = BoardModel()
}

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}
