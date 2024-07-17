import SwiftUI

enum ViewType {
    case introduction
    case survey
    case results(score: Int)
    case admin
}

struct ContentView: View {
    @State private var currentView: ViewType = .introduction

    var body: some View {
        VStack {
            switch currentView {
            case .introduction:
                IntroductionView(currentView: $currentView)
            case .survey:
                SurveyView(currentView: $currentView)
            case .results(let score):
                ResultsView(currentView: $currentView, score: score)
            case .admin:
                AdminPanelView(currentView: $currentView)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
