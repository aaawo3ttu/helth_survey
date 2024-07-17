import SwiftUI

struct ScoreView: View {
    var score: Int
    @Binding var currentView: ContentView.CurrentView

    var body: some View {
        VStack {
            Text("Your Score")
                .font(.largeTitle)
                .padding()
            
            Text("\(score)")
                .font(.system(size: 100))
                .padding()
            
            Button(action: {
                currentView = .introduction
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

struct ScoreView_Previews: PreviewProvider {
    @State static var currentView = ContentView.CurrentView.score(85)

    static var previews: some View {
        ScoreView(score: 85, currentView: $currentView)
    }
}
