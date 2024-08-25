import SwiftUI

// 学生の詳細な結果ビュー
struct StudentDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: SurveyViewModel // ViewModelを使用する
    let student: Student

    var body: some View {
        VStack {
            Text("\(student.name ?? "Unknown Student")'s Answers")
                .font(.largeTitle)
                .padding()

            List {
                // 学生の各回答を問題番号順に表示
                if let answers = student.answers as? Set<Answer> {
                    let sortedAnswers = Array(answers).sorted {
                        ($0.question?.orderIndex ?? 0) < ($1.question?.orderIndex ?? 0)
                    }
                    
                    ForEach(sortedAnswers, id: \.self) { answer in
                        VStack(alignment: .leading) {
                            Text(answer.question?.text ?? "Unknown Question")
                                .font(.headline)
                            Text("Selected Option: \(answer.selectedOption?.text ?? "None")")
                            Text("Score: \(answer.selectedOption?.score ?? 0)")
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .padding()
        .navigationTitle(student.name ?? "Unknown Student")
    }
}

struct StudentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // デモ用の学生データを作成
        let context = PersistenceController.preview.container.viewContext
        let student = Student(context: context)
        student.name = "Demo Student"
        
        let question = Question(context: context)
        question.text = "Sample Question"
        question.orderIndex = 1
        
        let option = Option(context: context)
        option.text = "Sample Option"
        option.score = 10
        
        let answer = Answer(context: context)
        answer.question = question
        answer.selectedOption = option
        answer.student = student
        
        student.addToAnswers(answer)
        
        return NavigationView {
            StudentDetailView(student: student)
                .environment(\.managedObjectContext, context)
                .environmentObject(SurveyViewModel(dataService: DataService(viewContext: context)))
        }
    }
}
