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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)] // orderIndexでソート
        do {
            questions = try dataService.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch questions: \(error.localizedDescription)")
        }
    }
    
    func fetchAllOptions() {
        let fetchRequest: NSFetchRequest<Option> = Option.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)] // orderIndexでソート
        do {
            allOptions = try dataService.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch options: \(error.localizedDescription)")
        }
    }
    
    func setStudent() {
        let newStudent = Student(context: dataService.viewContext)
        newStudent.studentID = UUID()
        newStudent.affiliation = ""
        self.student = newStudent
        newStudent.timestamp = Date() // タイムスタンプを設定
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
    
    func deleteStudent(_ student: Student) {
            dataService.viewContext.delete(student)
            
            do {
                try dataService.viewContext.save() // 削除を保存
            } catch {
                print("Failed to delete student: \(error.localizedDescription)")
            }
        }
    
    func addQuestion(text: String) {
        let newQuestion = Question(context: dataService.viewContext)
        newQuestion.questionID = UUID()
        newQuestion.text = text
        newQuestion.orderIndex = Int16(questions.count) // 新しい質問の順序を末尾に設定

        do {
            try dataService.viewContext.save()
            fetchQuestions()
            
            // 質問を追加したときにデフォルトの選択肢を1つ追加
            addOption(to: newQuestion, text: "Default Option", score: 0, imageData: nil, audioData: nil)
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
        newOption.orderIndex = Int16(question.optionsArray.count) // 新しい選択肢の順序を末尾に設定
        
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

    func updateQuestionOrderIndices() {
        for (index, question) in questions.enumerated() {
            question.orderIndex = Int16(index)
        }
        saveContext()
    }
    
    func updateOptionOrderIndices(for question: Question) {
        let sortedOptions = question.optionsArray.sorted(by: { $0.orderIndex < $1.orderIndex })
        for (index, option) in sortedOptions.enumerated() {
            option.orderIndex = Int16(index)
        }
        saveContext()
    }
    
    func saveContext() {
        do {
            try dataService.viewContext.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
