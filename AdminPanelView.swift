import SwiftUI
import CoreData

// 管理パネルビュー
struct AdminPanelView: View {
    @EnvironmentObject var viewModel: SurveyViewModel // ViewModelを使用する
    @Binding var currentView: ViewType
    
    @State private var selectedQuestion: Question?
    @State private var isAddingQuestion = false
    @State private var showDuplicateAlert = false
    @State private var questionToDuplicate: Question?

    var body: some View {
        NavigationView {
            List {
                // "View Student Scores"ボタンを追加して、学生のスコアリストビューに遷移するナビゲーションリンクを設定
                NavigationLink(destination: StudentListView().environmentObject(viewModel)) {
                    Text("View Student Scores")
                        .font(.title) // ボタンのテキストのフォントサイズを設定
                        .padding() // ボタンのパディングを設定
                        .background(Color.blue) // ボタンの背景色を青に設定
                        .foregroundColor(.white) // ボタンのテキスト色を白に設定
                        .cornerRadius(10) // ボタンの角を丸める
                }
                .padding() // ボタンの外側のパディングを設定

                // 質問リストを表示し、各質問を選択して編集できるようにする
                ForEach(viewModel.questions) { question in
                    NavigationLink(destination: QuestionDetailView(question: question, isNew: false).environmentObject(viewModel)) {
                        HStack {
                            Text("Q \(viewModel.questions.firstIndex(of: question)! + 1):")
                            Text(question.text ?? "Unknown Question")
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            duplicateQuestion(question)
                        }) {
                            Text("Duplicate")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
                .onDelete(perform: deleteQuestions) // 質問を削除するためのアクション
            }
            .navigationBarTitle("Manage Questions") // ナビゲーションバーのタイトルを設定
            .navigationBarItems(
                leading: Button(action: {
                    currentView = .introduction // "Back"ボタンを押すと、ビューをintroductionに戻す
                }) {
                    Text("Back")
                },
                trailing: Button(action: {
                    let newQuestion = Question(context: viewModel.dataService.viewContext)
                    newQuestion.questionID = UUID()
                    selectedQuestion = newQuestion
                    isAddingQuestion = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle) // "+"ボタンのアイコンサイズを設定
                }
            )

            // 質問詳細ビューを表示
            if let question = selectedQuestion {
                NavigationLink(destination: QuestionDetailView(question: question, isNew: true).environmentObject(viewModel), isActive: $isAddingQuestion) {
                    EmptyView()
                }
            } else {
                Text("Select a question to edit or add a new question")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
        .alert(isPresented: $showDuplicateAlert) {
            Alert(
                title: Text("Duplicate Question"),
                message: Text("Are you sure you want to duplicate this question?"),
                primaryButton: .default(Text("Yes")) {
                    if let questionToDuplicate = questionToDuplicate {
                        duplicateQuestionConfirmed(questionToDuplicate)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    // 質問を削除するための関数
    private func deleteQuestions(offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.questions[$0] }.forEach { question in
                viewModel.deleteQuestion(question)
            }
        }
    }

    // 質問を複製するための関数
    private func duplicateQuestion(_ question: Question) {
        questionToDuplicate = question
        showDuplicateAlert = true
    }

    // 質問の複製を確定するための関数
    private func duplicateQuestionConfirmed(_ question: Question) {
        let newQuestion = Question(context: viewModel.dataService.viewContext)
        newQuestion.questionID = UUID()
        newQuestion.text = question.text
        newQuestion.imageData = question.imageData
        newQuestion.audioData = question.audioData

        for option in question.optionsArray {
            let newOption = Option(context: viewModel.dataService.viewContext)
            newOption.optionID = UUID()
            newOption.text = option.text
            newOption.score = option.score
            newOption.imageData = option.imageData
            newOption.audioData = option.audioData
            newOption.question = newQuestion
            newQuestion.addToOptions(newOption)
        }

        viewModel.questions.append(newQuestion)
        viewModel.saveContext()
    }
}
