import SwiftUI

struct AdminPanelView: View {
    @EnvironmentObject var viewModel: SurveyViewModel // ViewModelを使用する
    @Binding var currentView: ViewType
    
    @State private var selectedQuestion: Question?
    @State private var isAddingQuestion = false
    @State private var showDuplicateAlert = false
    @State private var questionToDuplicate: Question?
    @State private var editMode: EditMode = .inactive // 管理するEditModeの状態

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
                ForEach(viewModel.questions.sorted(by: { $0.orderIndex < $1.orderIndex })) { question in
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
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        Button(action: {
                            if let index = viewModel.questions.firstIndex(of: question) {
                                deleteQuestions(at: IndexSet(integer: index))
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onMove(perform: moveQuestions) // 質問を移動するためのアクション
                .onDelete(perform: deleteQuestions) // 質問を削除するためのアクション
                
                // 新しい質問を追加するボタン（FABがあるためリストのボタンは省略）
                // Button(action: addNewQuestion) {
                //     HStack {
                //         Image(systemName: "plus.circle")
                //         Text("Add New Question")
                //     }
                //     .font(.title)
                //     .padding()
                //     .background(Color.green)
                //     .foregroundColor(.white)
                //     .cornerRadius(10)
                // }
                // .padding(.top, 10)
            }
            .navigationBarTitle("Manage Questions") // ナビゲーションバーのタイトルを設定
            .navigationBarItems(
                leading: Button(action: {
                    currentView = .introduction // "Back"ボタンを押すと、ビューをintroductionに戻す
                }) {
                    Text("Back")
                },
                trailing: HStack {
                    EditButton() // Editモードボタン
                }
            )
            .environment(\.editMode, $editMode) // EditModeをバインド

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
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(action: addNewQuestion)
                }
                .padding()
            }
        )
    }

    // 新しい質問を追加する関数
    private func addNewQuestion() {
        let newQuestion = Question(context: viewModel.dataService.viewContext)
        newQuestion.questionID = UUID()
        newQuestion.text = "New Question" // Add a default question text
        newQuestion.orderIndex = Int16(viewModel.questions.count) // 新しい質問の順序を末尾に設定
        viewModel.questions.append(newQuestion)
        selectedQuestion = newQuestion
        isAddingQuestion = true
        
        // 質問を追加したときにデフォルトの選択肢を1つ追加
        viewModel.addOption(to: newQuestion, text: "Default Option", score: 0, imageData: nil, audioData: nil)
        
        // Save context after adding the new question and option
        viewModel.saveContext()
    }

    // 質問を削除するための関数
    private func deleteQuestions(at offsets: IndexSet) {
        withAnimation {
            offsets.map { viewModel.questions[$0] }.forEach { question in
                viewModel.deleteQuestion(question)
            }
            viewModel.fetchQuestions() // 質問を再取得してリストを更新
        }
    }
    
    // 質問を移動するための関数
    private func moveQuestions(from source: IndexSet, to destination: Int) {
        viewModel.questions.move(fromOffsets: source, toOffset: destination)
        viewModel.updateQuestionOrderIndices()
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
        newQuestion.orderIndex = question.orderIndex + 1 // 複製時に順序を維持

        // オプションを複製し、orderIndexを維持
        for option in question.optionsArray.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let newOption = Option(context: viewModel.dataService.viewContext)
            newOption.optionID = UUID()
            newOption.text = option.text
            newOption.score = option.score
            newOption.imageData = option.imageData
            newOption.audioData = option.audioData
            newOption.orderIndex = option.orderIndex
            newOption.question = newQuestion
            newQuestion.addToOptions(newOption)
        }

        viewModel.questions.append(newQuestion)
        viewModel.updateQuestionOrderIndices() // 質問の順序を更新
        viewModel.saveContext()
    }
}

// フローティングアクションボタンのカスタムビュー
struct FloatingActionButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
                .shadow(radius: 10)
        }
    }
}
