//
//  GratingSimulator_macOSApp.swift
//  GratingSimulator-macOS
//
//  Created by Mark Barclay on 2/28/26.
//

//import SwiftUI
//
//@main
//struct GratingSimulator_macOSApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

import SwiftUI
import SwiftData

// MARK: - Main App


@main
struct GratingSimulator_macOSApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentViewMacOS()
        }
        .modelContainer(sharedModelContainer)
    }
}
