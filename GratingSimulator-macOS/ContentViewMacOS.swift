//
//  ContentViewMacOS.swift
//  GratingSimulator-macOS
//
//  Created by Mark Barclay on 2/28/26.
//

import SwiftUI

struct ContentViewMacOS: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Laser Grating Simulator!")
        }
        .padding()
    }
}

#Preview {
    ContentViewMacOS()
}
