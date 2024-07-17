//
//  helth_surveyApp.swift
//  helth_survey
//
//  Created by 杉山新 on 2024/07/17.
//

import SwiftUI

@main
struct helth_surveyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
