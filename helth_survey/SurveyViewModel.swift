import SwiftUI
import CoreData

class SurveyViewModel: ObservableObject {
    @Published var currentView: ViewType = .introduction
    @Published var questions: [Question] = []
    @Published var allOptions: [Option] = []
    @Published var student: Student?
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
    
    func setStudent(age: Int32) {
        let newStudent = Student(context: dataService.viewContext)
        newStudent.studentID = UUID()
        newStudent.age = age
        newStudent.affiliation = ""
        self.student = newStudent
    }
    
    func saveAnswer(for question: Question, selectedOption: Option) {
        guard let student = student else { return }
        
        let newAnswer = Answer(context: dataService.viewContext)
        newAnswer.answerID = UUID()
        newAnswer.question = question
        newAnswer.selectedOption = selectedOption
        newAnswer.answerData = Date()
        newAnswer.student = student
        
        do {
            try dataService.viewContext.save()
        } catch {
            print("Failed to save answer: \(error.localizedDescription)")
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
    
    func calculateAndSaveStudentScores() -> [Student: Int] {
        let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
        do {
            let students = try dataService.viewContext.fetch(fetchRequest)
            var studentScores: [Student: Int] = [:]
            for student in students {
                if let answers = student.answers as? Set<Answer> {
                    let totalScore = answers.reduce(0) { $0 + Int($1.selectedOption?.score ?? 0) }
                    let averageScore = answers.count > 0 ? totalScore / answers.count : 0
                    
                    // スコアをResultエンティティに保存
                    let result = Result(context: dataService.viewContext)
                    result.student = student
                    result.totalScore = Int32(averageScore)
                    studentScores[student] = averageScore
                }
            }
            try dataService.viewContext.save() // データを保存
            return studentScores
        } catch {
            print("Failed to fetch students: \(error.localizedDescription)")
            return [:]
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

    func saveContext() {
        do {
            try dataService.viewContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
