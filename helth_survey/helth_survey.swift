import SwiftUI

@main
struct helth_survey: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let dataService = DataService(viewContext: persistenceController.container.viewContext)
            let surveyViewModel = SurveyViewModel(dataService: dataService)
            let adminViewModel = AdminViewModel(dataService: dataService)
            
            ContentView(surveyViewModel: surveyViewModel, adminViewModel: adminViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(surveyViewModel)
                .environmentObject(adminViewModel)
        }
    }
}
