import SwiftUI
import CoreData

struct SurveyView: View {
    @Binding var currentView: ContentView.CurrentView

    @FetchRequest(
        entity: Question.entity(),
        sortDescriptors: []
    ) var questions: FetchedResults<Question>

    @State private var currentQuestionIndex = 0
    @State private var selectedOption: Option?
    @State private var score = 0

    var body: some View {
        VStack {
            if currentQuestionIndex < questions.count {
                let question = questions[currentQuestionIndex]
                
                Text(question.text ?? "No Question Text")
                    .font(.title)
                    .padding()
                
                ForEach(question.optionsArray, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        score += Int(option.score)
                        currentQuestionIndex += 1
                        if currentQuestionIndex >= questions.count {
                            currentView = .score(score)
                        }
                    }) {
                        Text(option.text ?? "No Option Text")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 5)
                    }
                }
            } else {
                Text("Thank you for completing the survey!")
                    .font(.title)
                    .padding()
            }
        }
        .padding()
    }
}

struct SurveyView_Previews: PreviewProvider {
    @State static var currentView = ContentView.CurrentView.survey

    static var previews: some View {
        SurveyView(currentView: $currentView)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
