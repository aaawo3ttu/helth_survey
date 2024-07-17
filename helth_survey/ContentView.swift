import SwiftUI

struct ContentView: View {
    @State private var currentView: CurrentView = .introduction

    enum CurrentView {
        case introduction
        case survey
        case score(Int)
    }

    var body: some View {
        VStack {
            switch currentView {
            case .introduction:
                IntroductionView(currentView: $currentView)
            case .survey:
                SurveyView(currentView: $currentView)
            case .score(let score):
                ScoreView(score: score, currentView: $currentView)
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
