import SwiftUI
import CoreData

class AdminViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var allOptions: [Option] = []
    @Published var selectedQuestion: Question?
    @Published var selectedOption: Option?
    @Published var isAddingQuestion = false
    @Published var isAddingOption = false
    let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
        fetchQuestions()
        fetchAllOptions()
    }
    
    func fetchQuestions() {
        let fetchRequest: NSFetchRequest<Question> = Question.fetchRequest()
        do {
            questions = try dataService.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch questions: \(error.localizedDescription)")
        }
    }
    
    func fetchAllOptions() {
        let fetchRequest: NSFetchRequest<Option> = Option.fetchRequest()
        do {
            allOptions = try dataService.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch options: \(error.localizedDescription)")
        }
    }
    
    func addQuestion(text: String) {
        let newQuestion = Question(context: dataService.viewContext)
        newQuestion.questionID = UUID()
        newQuestion.text = text

        do {
            try dataService.viewContext.save()
            fetchQuestions()
        } catch {
            print("Failed to save question: \(error.localizedDescription)")
        }
    }
    
    func deleteQuestion(_ question: Question) {
        dataService.viewContext.delete(question)
        do {
            try dataService.viewContext.save()
            fetchQuestions()
        } catch {
            print("Failed to delete question: \(error.localizedDescription)")
        }
    }

    func addOption(to question: Question, text: String, score: Int16, imageData: Data?, audioData: Data?) {
        let newOption = Option(context: dataService.viewContext)
        newOption.optionID = UUID()
        newOption.text = text
        newOption.score = score
        newOption.imageData = imageData
        newOption.audioData = audioData
        newOption.question = question
        
        do {
            try dataService.viewContext.save()
            fetchAllOptions()
        } catch {
            print("Failed to save option: \(error.localizedDescription)")
        }
    }
    
    func deleteOption(_ option: Option) {
        dataService.viewContext.delete(option)
        do {
            try dataService.viewContext.save()
            fetchAllOptions()
        } catch {
            print("Failed to delete option: \(error.localizedDescription)")
        }
    }

    func saveContext() {
        do {
            try dataService.viewContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
