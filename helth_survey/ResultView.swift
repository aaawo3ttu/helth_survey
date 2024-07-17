import SwiftUI

struct ResultsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Answer.entity(), sortDescriptors: []) private var answers: FetchedResults<Answer>
    @Binding var currentView: ViewType
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

    private var totalScore: Int {
        return answers.reduce(0) { $0 + Int($1.selectedOption?.score ?? 0) }
    }
}
