import SwiftUI
import CoreData

struct QuestionView: View {
    @FetchRequest(
        entity: Question.entity(),
        sortDescriptors: []
    ) var questions: FetchedResults<Question>

    var body: some View {
        List(questions) { question in
            Text(question.text ?? "No Text")
        }
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
