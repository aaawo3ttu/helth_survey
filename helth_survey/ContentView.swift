import SwiftUI

struct ContentView: View {
    @StateObject private var surveyViewModel: SurveyViewModel
    @StateObject private var adminViewModel: AdminViewModel

    init(surveyViewModel: SurveyViewModel, adminViewModel: AdminViewModel) {
        _surveyViewModel = StateObject(wrappedValue: surveyViewModel)
        _adminViewModel = StateObject(wrappedValue: adminViewModel)
    }

    var body: some View {
        VStack {
            switch surveyViewModel.currentView {
            case .introduction:
                IntroductionView(currentView: $surveyViewModel.currentView)
                    .environmentObject(surveyViewModel)
            case .survey:
                SurveyView(currentView: $surveyViewModel.currentView)
                    .environmentObject(surveyViewModel)
            case .results(let score):
                ResultView(score: score)
                    .environmentObject(surveyViewModel)
            case .admin:
                AdminPanelView(currentView: $surveyViewModel.currentView)
                    .environmentObject(surveyViewModel)
                    .environmentObject(adminViewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let dataService = DataService(viewContext: PersistenceController.preview.container.viewContext)
        ContentView(surveyViewModel: SurveyViewModel(dataService: dataService), adminViewModel: AdminViewModel(dataService: dataService))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
