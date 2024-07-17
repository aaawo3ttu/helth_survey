import SwiftUI
import CoreData

class QuestionViewModel: ObservableObject {
    @Published var questions: [Question] = []
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchQuestions()
    }

    func fetchQuestions() {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        do {
            questions = try context.fetch(request)
        } catch {
            print("Failed to fetch questions: \(error)")
        }
    }
}
