//
//  Item.swift
//  GratingSimulator
//
//  Created by Mark Barclay on 12/22/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
