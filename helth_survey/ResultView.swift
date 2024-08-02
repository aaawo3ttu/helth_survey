import SwiftUI
import CoreData

// 結果ビュー
struct ResultView: View {
    @EnvironmentObject var viewModel: SurveyViewModel
    var score: Int

    var body: some View {
        VStack {
            Text("Your Score")
                .font(.largeTitle)
                .padding()
            
            Text("\(score)")
                .font(.system(size: 100))
                .padding()
            
            Button(action: {
                viewModel.currentView = .introduction
            }) {
                Text("Done")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
